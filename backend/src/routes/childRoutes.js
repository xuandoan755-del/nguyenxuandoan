const express = require('express');
const router = express.Router();
const dbService = require('../services/dbService');
const { authenticateToken } = require('../middleware/auth');

// Lấy danh sách trẻ em
router.get('/', authenticateToken, (req, res) => {
  const children = dbService.getCollection('children');

  if (req.user.role === 'admin' || req.user.role === 'staff') {
    return res.status(200).json({ data: children, total: children.length });
  }

  // Khách hàng (phụ huynh) chỉ xem danh sách con của mình
  const myChildren = children.filter(c => c.parentId === req.user.id);
  res.status(200).json({ data: myChildren, total: myChildren.length });
});

// Thêm hồ sơ trẻ mới
router.post('/', authenticateToken, (req, res) => {
  const { name, age, avatar, deviceModel } = req.body;

  if (!name || age === undefined) {
    return res.status(400).json({
      error: { code: 'INVALID_INPUT', message: 'Vui lòng nhập tên và tuổi của trẻ' }
    });
  }

  const db = dbService.read();
  const newChild = {
    id: 'c_' + Date.now(),
    parentId: req.user.id,
    name,
    age: parseInt(age, 10),
    avatar: avatar || '👦',
    isSafe: true,
    screenTimeMinutesToday: 0,
    lastActive: new Date().toISOString(),
    deviceModel: deviceModel || 'Thiết bị di động'
  };

  db.children.push(newChild);
  dbService.write(db);

  res.status(201).json({ message: 'Thêm hồ sơ trẻ thành công', data: newChild });
});

// Cập nhật thông tin hoặc trạng thái an toàn
router.put('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { name, age, avatar, isSafe, deviceModel, screenTimeMinutesToday } = req.body;

  const db = dbService.read();
  const child = db.children.find(c => c.id === id);

  if (!child) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy hồ sơ trẻ em' }
    });
  }

  // Kiểm tra quyền
  if (req.user.role === 'customer' && child.parentId !== req.user.id) {
    return res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Bạn không có quyền chỉnh sửa hồ sơ này' }
    });
  }

  if (name !== undefined) child.name = name;
  if (age !== undefined) child.age = parseInt(age, 10);
  if (avatar !== undefined) child.avatar = avatar;
  if (isSafe !== undefined) child.isSafe = isSafe;
  if (deviceModel !== undefined) child.deviceModel = deviceModel;
  if (screenTimeMinutesToday !== undefined) child.screenTimeMinutesToday = screenTimeMinutesToday;
  child.lastActive = new Date().toISOString();

  dbService.write(db);
  res.status(200).json({ message: 'Cập nhật thành công', data: child });
});

// Đổi trạng thái An toàn / Cảnh báo
router.patch('/:id/toggle-safe', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const child = db.children.find(c => c.id === id);

  if (!child) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy hồ sơ trẻ em' }
    });
  }

  child.isSafe = !child.isSafe;
  dbService.write(db);

  res.status(200).json({
    message: child.isSafe ? 'Đã chuyển sang trạng thái AN TOÀN' : 'Đã cảnh báo CẦN CHÚ Ý',
    isSafe: child.isSafe
  });
});

// Xóa hồ sơ trẻ
router.delete('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const child = db.children.find(c => c.id === id);

  if (!child) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy hồ sơ trẻ cần xóa' }
    });
  }

  if (req.user.role === 'customer' && child.parentId !== req.user.id) {
    return res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Bạn không có quyền xóa hồ sơ này' }
    });
  }

  // Xóa luôn các rules liên quan
  db.children = db.children.filter(c => c.id !== id);
  db.rules = db.rules.filter(r => r.childId !== id);
  dbService.write(db);

  res.status(200).json({ message: 'Đã xóa hồ sơ trẻ và các quy tắc liên quan thành công' });
});

module.exports = router;
