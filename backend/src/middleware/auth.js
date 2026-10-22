const jwt = require('jsonwebtoken');
const dbService = require('../services/dbService');

const JWT_SECRET = process.env.JWT_SECRET || 'baoan_secret_key_2026_xuan_doan_238600510';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Yêu cầu token xác thực Bearer token'
      }
    });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        error: {
          code: 'FORBIDDEN',
          message: 'Token không hợp lệ hoặc đã hết hạn'
        }
      });
    }

    // Kiểm tra user có tồn tại và có bị khóa không
    const users = dbService.getCollection('users');
    const existing = users.find(u => u.id === user.id);
    if (!existing) {
      return res.status(404).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'Người dùng không tồn tại'
        }
      });
    }

    if (existing.isLocked) {
      return res.status(403).json({
        error: {
          code: 'USER_LOCKED',
          message: 'Tài khoản này hiện đang bị khóa'
        }
      });
    }

    req.user = existing;
    next();
  });
}

function requireRole(roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        error: {
          code: 'PERMISSION_DENIED',
          message: 'Bạn không có quyền thực hiện thao tác này'
        }
      });
    }
    next();
  };
}

module.exports = {
  authenticateToken,
  requireRole,
  JWT_SECRET
};
