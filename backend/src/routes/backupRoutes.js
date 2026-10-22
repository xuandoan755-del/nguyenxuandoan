const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const dbService = require('../services/dbService');
const { authenticateToken } = require('../middleware/auth');

// 1. Tạo bản sao lưu Snapshot (POST /api/v1/backups)
router.post('/', authenticateToken, (req, res) => {
  const { label, scope } = req.body;
  const db = dbService.read();

  // Snapshot dữ liệu theo phạm vi tài khoản
  let targetChildren = [];
  let targetRules = [];
  let targetTickets = [];

  if (req.user.role === 'admin' && scope === 'system') {
    targetChildren = db.children;
    targetRules = db.rules;
    targetTickets = db.tickets;
  } else {
    targetChildren = db.children.filter(c => c.parentId === req.user.id);
    const childIds = new Set(targetChildren.map(c => c.id));
    targetRules = db.rules.filter(r => childIds.has(r.childId));
    targetTickets = db.tickets.filter(t => t.customerId === req.user.id);
  }

  const snapshotPayload = {
    schemaVersion: 1,
    app: 'bao-an',
    scope: { type: scope || 'account', ownerId: req.user.id },
    createdAt: new Date().toISOString(),
    sourceVersion: '1.0.0',
    data: {
      children: targetChildren,
      appRules: targetRules,
      supportTickets: targetTickets
    }
  };

  const payloadString = JSON.stringify(snapshotPayload);
  const checksumSha256 = crypto.createHash('sha256').update(payloadString).digest('hex');

  const newBackup = {
    id: 'bk_' + Date.now(),
    ownerId: req.user.id,
    label: label || 'Bản sao lưu thủ công',
    scope: scope || 'account',
    status: 'completed',
    createdAt: new Date().toISOString(),
    completedAt: new Date().toISOString(),
    sizeBytes: Buffer.byteLength(payloadString, 'utf8'),
    recordCounts: {
      children: targetChildren.length,
      appRules: targetRules.length,
      supportTickets: targetTickets.length
    },
    checksumSha256,
    snapshotData: snapshotPayload
  };

  db.backups = db.backups || [];
  db.backups.push(newBackup);
  dbService.write(db);

  const { snapshotData, ...meta } = newBackup;
  res.status(201).json({
    message: 'Tạo bản sao lưu snapshot thành công!',
    data: meta
  });
});

// 2. Lấy danh sách sao lưu (GET /api/v1/backups)
router.get('/', authenticateToken, (req, res) => {
  const db = dbService.read();
  const backups = db.backups || [];

  const myBackups = (req.user.role === 'admin')
    ? backups
    : backups.filter(b => b.ownerId === req.user.id);

  // Ẩn snapshotData ở danh sách
  const safeList = myBackups.map(({ snapshotData, ...meta }) => meta);
  res.status(200).json({ data: safeList, total: safeList.length });
});

// 3. Khôi phục dữ liệu từ bản sao lưu (POST /api/v1/backups/:id/restore)
router.post('/:id/restore', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { mode } = req.body; // 'merge' hoặc 'replace'

  const db = dbService.read();
  const backup = (db.backups || []).find(b => b.id === id);

  if (!backup) {
    return res.status(404).json({
      error: { code: 'BACKUP_NOT_FOUND', message: 'Không tìm thấy bản sao lưu' }
    });
  }

  if (req.user.role !== 'admin' && backup.ownerId !== req.user.id) {
    return res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Bạn không có quyền khôi phục bản sao lưu này' }
    });
  }

  const snapshot = backup.snapshotData;
  if (!snapshot || !snapshot.data) {
    return res.status(422).json({
      error: { code: 'INVALID_BACKUP', message: 'Dữ liệu bản sao lưu không hợp lệ' }
    });
  }

  const { children = [], appRules = [], supportTickets = [] } = snapshot.data;

  if (mode === 'replace') {
    // Thay thế toàn bộ dữ liệu của phụ huynh này
    db.children = db.children.filter(c => c.parentId !== req.user.id).concat(children);
    const myChildIds = new Set(children.map(c => c.id));
    db.rules = db.rules.filter(r => !myChildIds.has(r.childId)).concat(appRules);
    db.tickets = db.tickets.filter(t => t.customerId !== req.user.id).concat(supportTickets);
  } else {
    // Merge: Thêm những bản ghi chưa tồn tại
    const existingChildIds = new Set(db.children.map(c => c.id));
    for (const c of children) {
      if (!existingChildIds.has(c.id)) db.children.push(c);
    }

    const existingRuleIds = new Set(db.rules.map(r => r.id));
    for (const r of appRules) {
      if (!existingRuleIds.has(r.id)) db.rules.push(r);
    }

    const existingTicketIds = new Set(db.tickets.map(t => t.id));
    for (const t of supportTickets) {
      if (!existingTicketIds.has(t.id)) db.tickets.push(t);
    }
  }

  dbService.write(db);

  res.status(200).json({
    message: 'Khôi phục dữ liệu từ bản sao lưu thành công!',
    restoredCounts: {
      children: children.length,
      appRules: appRules.length,
      supportTickets: supportTickets.length
    }
  });
});

// 4. Xóa bản sao lưu (DELETE /api/v1/backups/:id)
router.delete('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const initialLength = (db.backups || []).length;
  db.backups = (db.backups || []).filter(b => b.id !== id);

  if (db.backups.length === initialLength) {
    return res.status(404).json({
      error: { code: 'BACKUP_NOT_FOUND', message: 'Không tìm thấy bản sao lưu cần xóa' }
    });
  }

  dbService.write(db);
  res.status(200).json({ message: 'Xóa bản sao lưu thành công' });
});

module.exports = router;
