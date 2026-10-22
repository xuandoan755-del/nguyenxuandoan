const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const dbService = require('../services/dbService');
const { authenticateToken, JWT_SECRET } = require('../middleware/auth');

// Store OTPs in-memory / dbService
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// 1. Đăng ký tài khoản (Tạo OTP xác thực)
router.post('/register', (req, res) => {
  const { username, email, password, fullName, phone, role } = req.body;

  if (!username || !email || !password || !fullName) {
    return res.status(400).json({
      error: { code: 'INVALID_INPUT', message: 'Vui lòng điền đầy đủ các thông tin bắt buộc' }
    });
  }

  const db = dbService.read();
  const existingUser = db.users.find(u => u.username === username || u.email.toLowerCase() === email.toLowerCase());
  if (existingUser) {
    return res.status(400).json({
      error: { code: 'USER_EXISTS', message: 'Tên đăng nhập hoặc Email đã tồn tại trong hệ thống' }
    });
  }

  const otp = generateOtp();
  db.otps = db.otps || {};
  db.otps[email.toLowerCase()] = {
    otp,
    expiresAt: Date.now() + 5 * 60 * 1000,
    tempUser: {
      id: 'u_' + Date.now(),
      username,
      email: email.toLowerCase(),
      password,
      fullName,
      phone: phone || '',
      role: role || 'customer',
      isLocked: false,
      createdAt: new Date().toISOString()
    }
  };
  dbService.write(db);

  res.status(200).json({
    message: 'Mã xác thực OTP đã được tạo thành công!',
    email: email.toLowerCase(),
    demoOtp: otp,
    note: 'Chế độ Demo: Dùng mã OTP này để hoàn tất xác thực'
  });
});

// 2. Đăng nhập (Yêu cầu xác thực OTP 2 lớp)
router.post('/login', (req, res) => {
  const { usernameOrEmail, password } = req.body;

  if (!usernameOrEmail || !password) {
    return res.status(400).json({
      error: { code: 'INVALID_CREDENTIALS', message: 'Vui lòng nhập tên đăng nhập và mật khẩu' }
    });
  }

  const db = dbService.read();
  const query = usernameOrEmail.toLowerCase();
  const user = db.users.find(u => (u.username.toLowerCase() === query || u.email.toLowerCase() === query) && u.password === password);

  if (!user) {
    return res.status(401).json({
      error: { code: 'AUTH_FAILED', message: 'Tên đăng nhập hoặc mật khẩu không chính xác' }
    });
  }

  if (user.isLocked) {
    return res.status(403).json({
      error: { code: 'USER_LOCKED', message: 'Tài khoản này đã bị khóa bởi Quản trị viên' }
    });
  }

  const otp = generateOtp();
  db.otps = db.otps || {};
  db.otps[user.email.toLowerCase()] = {
    otp,
    expiresAt: Date.now() + 5 * 60 * 1000,
    userId: user.id
  };
  dbService.write(db);

  res.status(200).json({
    message: 'Xác thực lớp 1 thành công. Vui lòng nhập mã OTP để hoàn tất đăng nhập!',
    email: user.email,
    demoOtp: otp,
    userRole: user.role
  });
});

// 3. Xác thực mã OTP 2 lớp (hoàn tất đăng nhập hoặc đăng ký)
router.post('/verify-otp', (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) {
    return res.status(400).json({
      error: { code: 'INVALID_OTP', message: 'Vui lòng cung cấp Email và mã OTP' }
    });
  }

  const db = dbService.read();
  const otpRecord = db.otps && db.otps[email.toLowerCase()];

  if (!otpRecord) {
    return res.status(400).json({
      error: { code: 'OTP_NOT_FOUND', message: 'Không tìm thấy yêu cầu OTP hoặc mã đã bị hủy' }
    });
  }

  if (Date.now() > otpRecord.expiresAt) {
    delete db.otps[email.toLowerCase()];
    dbService.write(db);
    return res.status(400).json({
      error: { code: 'OTP_EXPIRED', message: 'Mã OTP đã hết hiệu lực, vui lòng yêu cầu mã mới' }
    });
  }

  if (otpRecord.otp !== otp.trim()) {
    return res.status(400).json({
      error: { code: 'OTP_MISMATCH', message: 'Mã OTP không chính xác, vui lòng thử lại' }
    });
  }

  let finalUser = null;
  if (otpRecord.tempUser) {
    // Hoàn tất đăng ký
    finalUser = otpRecord.tempUser;
    db.users.push(finalUser);
  } else if (otpRecord.userId) {
    // Hoàn tất đăng nhập
    finalUser = db.users.find(u => u.id === otpRecord.userId);
  }

  delete db.otps[email.toLowerCase()];
  dbService.write(db);

  if (!finalUser) {
    return res.status(500).json({
      error: { code: 'USER_ERROR', message: 'Lỗi không xác định khi hoàn tất người dùng' }
    });
  }

  const token = jwt.sign(
    { id: finalUser.id, username: finalUser.username, role: finalUser.role },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  const { password, ...safeUser } = finalUser;

  res.status(200).json({
    message: 'Xác thực thành công!',
    token,
    user: safeUser
  });
});

// 4. Lấy thông tin user hiện tại
router.get('/me', authenticateToken, (req, res) => {
  const { password, ...safeUser } = req.user;
  res.status(200).json({ data: safeUser });
});

module.exports = router;
