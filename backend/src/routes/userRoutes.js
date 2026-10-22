const express = require('express');
const router = express.Router();
const dbService = require('../services/dbService');
const { authenticateToken, requireRole } = require('../middleware/auth');

// Lấy danh sách người dùng (Admin)
router.get('/', authenticateToken, requireRole(['admin']), (req, res) => {
  const users = dbService.getCollection('users');
  const safeUsers = users.map(({ password, ...u }) => u);
  res.status(200).json({ data: safeUsers, total: safeUsers.length });
});

// Thêm người dùng mới (Admin)
router.post('/', authenticateToken, requireRole(['admin']), (req, res) => {
  const { username, email, password, fullName, phone, role } = req.body;

  if (!username || !email || !password || !fullName) {
    return res.status(400).json({
      error: { code: 'INVALID_INPUT', message: 'Vui lòng nhập đầy đủ thông tin người dùng' }
    });
  }

  const db = dbService.read();
  if (db.users.some(u => u.username === username || u.email.toLowerCase() === email.toLowerCase())) {
    return res.status(400).json({
      error: { code: 'USER_EXISTS', message: 'Tên đăng nhập hoặc Email đã tồn tại' }
    });
  }

  const newUser = {
    id: 'u_' + Date.now(),
    username,
    email: email.toLowerCase(),
    password,
    fullName,
    phone: phone || '',
    role: role || 'customer',
    isLocked: false,
    createdAt: new Date().toISOString()
  };

  db.users.push(newUser);
  dbService.write(db);

  const { password: _, ...safeUser } = newUser;
  res.status(201).json({ message: 'Tạo tài khoản thành công', data: safeUser });
});

// Cập nhật người dùng (Admin)
router.put('/:id', authenticateToken, requireRole(['admin']), (req, res) => {
  const { id } = req.params;
  const { fullName, phone, role, password } = req.body;

  const db = dbService.read();
  const index = db.users.findIndex(u => u.id === id);
  if (index === -1) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy người dùng' }
    });
  }

  if (fullName) db.users[index].fullName = fullName;
  if (phone !== undefined) db.users[index].phone = phone;
  if (role) db.users[index].role = role;
  if (password) db.users[index].password = password;

  dbService.write(db);

  const { password: _, ...safeUser } = db.users[index];
  res.status(200).json({ message: 'Cập nhật thành công', data: safeUser });
});

// Khóa / Mở khóa người dùng (Admin)
router.patch('/:id/toggle-lock', authenticateToken, requireRole(['admin']), (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const user = db.users.find(u => u.id === id);
  if (!user) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy người dùng' }
    });
  }

  if (user.role === 'admin' && user.id === req.user.id) {
    return res.status(400).json({
      error: { code: 'ACTION_FORBIDDEN', message: 'Không thể tự khóa tài khoản Admin đang đăng nhập' }
    });
  }

  user.isLocked = !user.isLocked;
  dbService.write(db);

  res.status(200).json({
    message: user.isLocked ? 'Đã khóa tài khoản thành công' : 'Đã mở khóa tài khoản thành công',
    isLocked: user.isLocked
  });
});

// Xóa người dùng (Admin)
router.delete('/:id', authenticateToken, requireRole(['admin']), (req, res) => {
  const { id } = req.params;

  if (id === req.user.id) {
    return res.status(400).json({
      error: { code: 'ACTION_FORBIDDEN', message: 'Không thể tự xóa tài khoản đang đăng nhập' }
    });
  }

  const db = dbService.read();
  const initialLength = db.users.length;
  db.users = db.users.filter(u => u.id !== id);

  if (db.users.length === initialLength) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy người dùng cần xóa' }
    });
  }

  dbService.write(db);
  res.status(200).json({ message: 'Xóa người dùng thành công' });
});

module.exports = router;
