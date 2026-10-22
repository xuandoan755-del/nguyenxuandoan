const express = require('express');
const router = express.Router();
const dbService = require('../services/dbService');
const { authenticateToken } = require('../middleware/auth');

// Lấy danh sách quy tắc ứng dụng
router.get('/', authenticateToken, (req, res) => {
  const { childId } = req.query;
  const rules = dbService.getCollection('rules');

  if (childId) {
    const filtered = rules.filter(r => r.childId === childId);
    return res.status(200).json({ data: filtered, total: filtered.length });
  }

  res.status(200).json({ data: rules, total: rules.length });
});

// Thêm quy tắc ứng dụng
router.post('/', authenticateToken, (req, res) => {
  const { childId, appName, packageName, timeLimitMinutes, isLocked, category } = req.body;

  if (!childId || !appName) {
    return res.status(400).json({
      error: { code: 'INVALID_INPUT', message: 'Vui lòng cung cấp mã hồ sơ trẻ và tên ứng dụng' }
    });
  }

  const db = dbService.read();
  const newRule = {
    id: 'r_' + Date.now(),
    childId,
    appName,
    packageName: packageName || 'com.app.' + appName.toLowerCase().replace(/\s+/g, ''),
    timeLimitMinutes: parseInt(timeLimitMinutes || 60, 10),
    isLocked: Boolean(isLocked),
    isEnabled: true,
    category: category || 'Khác'
  };

  db.rules.push(newRule);
  dbService.write(db);

  res.status(201).json({ message: 'Tạo quy tắc mới thành công', data: newRule });
});

// Bật / tắt quy tắc (toggle)
router.patch('/:id/toggle-enable', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const rule = db.rules.find(r => r.id === id);

  if (!rule) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy quy tắc' }
    });
  }

  rule.isEnabled = !rule.isEnabled;
  dbService.write(db);

  res.status(200).json({
    message: rule.isEnabled ? 'Đã bật quy tắc' : 'Đã tắt quy tắc',
    isEnabled: rule.isEnabled
  });
});

// Cập nhật quy tắc
router.put('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { appName, timeLimitMinutes, isLocked, isEnabled, category } = req.body;

  const db = dbService.read();
  const rule = db.rules.find(r => r.id === id);

  if (!rule) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy quy tắc' }
    });
  }

  if (appName !== undefined) rule.appName = appName;
  if (timeLimitMinutes !== undefined) rule.timeLimitMinutes = parseInt(timeLimitMinutes, 10);
  if (isLocked !== undefined) rule.isLocked = Boolean(isLocked);
  if (isEnabled !== undefined) rule.isEnabled = Boolean(isEnabled);
  if (category !== undefined) rule.category = category;

  dbService.write(db);
  res.status(200).json({ message: 'Cập nhật quy tắc thành công', data: rule });
});

// Xóa quy tắc
router.delete('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const initialLength = db.rules.length;
  db.rules = db.rules.filter(r => r.id !== id);

  if (db.rules.length === initialLength) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy quy tắc cần xóa' }
    });
  }

  dbService.write(db);
  res.status(200).json({ message: 'Xóa quy tắc thành công' });
});

module.exports = router;
