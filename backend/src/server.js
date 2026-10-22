require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const childRoutes = require('./routes/childRoutes');
const ruleRoutes = require('./routes/ruleRoutes');
const ticketRoutes = require('./routes/ticketRoutes');
const backupRoutes = require('./routes/backupRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware cơ bản
app.use(cors());
app.use(express.json());

// Giao diện tài liệu API (Interactive UI)
app.get(['/', '/api-docs'], (req, res) => {
  res.send(`
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Bảo An - Web API Backend Documentation</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 24px; line-height: 1.6; }
    .container { max-width: 900px; margin: 0 auto; background: #1e293b; padding: 32px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
    h1 { color: #38bdf8; margin-top: 0; display: flex; align-items: center; gap: 12px; }
    .badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: bold; }
    .badge-get { background: #0284c7; }
    .badge-post { background: #16a34a; }
    .badge-put { background: #d97706; }
    .badge-patch { background: #7c3aed; }
    .badge-delete { background: #dc2626; }
    .endpoint { background: #0f172a; padding: 12px 16px; border-radius: 8px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; border-left: 4px solid #38bdf8; }
    .path { font-family: monospace; font-size: 15px; color: #e2e8f0; }
    .desc { color: #94a3b8; font-size: 13px; }
    .group-title { color: #f1f5f9; border-bottom: 1px solid #334155; padding-bottom: 6px; margin-top: 28px; }
    .meta-box { background: #334155; padding: 16px; border-radius: 8px; margin-bottom: 24px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🛡️ BẢO AN - RESTful Web API Server</h1>
    <div class="meta-box">
      <div><strong>Sinh viên:</strong> Nguyễn Xuân Đoàn (MSV: 238600510) - Nhóm DA</div>
      <div><strong>Trạng thái máy chủ:</strong> <span style="color: #4ade80;">● Đang hoạt động (Running)</span> tại cổng <code>${PORT}</code></div>
      <div><strong>Cơ sở dữ liệu:</strong> JSON Persistent Database (Tự động nạp Seed Data tài khoản Admin, Staff, Khách hàng)</div>
    </div>

    <h3 class="group-title">1. Xác thực & Phân quyền (Auth & 2FA OTP)</h3>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/auth/register</span></div><span class="desc">Đăng ký tài khoản + Gửi OTP</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/auth/login</span></div><span class="desc">Đăng nhập xác thực 2 lớp (Tạo OTP)</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/auth/verify-otp</span></div><span class="desc">Xác thực OTP & Cấp JWT Token</span></div>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/auth/me</span></div><span class="desc">Lấy thông tin tài khoản hiện tại</span></div>

    <h3 class="group-title">2. Quản trị người dùng (Admin User Management)</h3>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/users</span></div><span class="desc">Danh sách tài khoản toàn hệ thống</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/users</span></div><span class="desc">Thêm người dùng mới</span></div>
    <div class="endpoint"><div><span class="badge badge-put">PUT</span> <span class="path">/api/v1/users/:id</span></div><span class="desc">Cập nhật thông tin người dùng</span></div>
    <div class="endpoint"><div><span class="badge badge-patch">PATCH</span> <span class="path">/api/v1/users/:id/toggle-lock</span></div><span class="desc">Khóa / Mở khóa tài khoản</span></div>
    <div class="endpoint"><div><span class="badge badge-delete">DELETE</span> <span class="path">/api/v1/users/:id</span></div><span class="desc">Xóa tài khoản</span></div>

    <h3 class="group-title">3. Quản lý Hồ sơ Trẻ & Thiết bị (Children & Devices)</h3>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/children</span></div><span class="desc">Lấy danh sách hồ sơ trẻ</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/children</span></div><span class="desc">Thêm hồ sơ trẻ mới</span></div>
    <div class="endpoint"><div><span class="badge badge-put">PUT</span> <span class="path">/api/v1/children/:id</span></div><span class="desc">Cập nhật hồ sơ trẻ</span></div>
    <div class="endpoint"><div><span class="badge badge-patch">PATCH</span> <span class="path">/api/v1/children/:id/toggle-safe</span></div><span class="desc">Đổi trạng thái An toàn / Cảnh báo</span></div>
    <div class="endpoint"><div><span class="badge badge-delete">DELETE</span> <span class="path">/api/v1/children/:id</span></div><span class="desc">Xóa hồ sơ trẻ</span></div>

    <h3 class="group-title">4. Quản lý Giới hạn Ứng dụng (App Rules)</h3>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/rules</span></div><span class="desc">Lấy danh sách quy tắc chặn/giới hạn</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/rules</span></div><span class="desc">Thêm quy tắc mới</span></div>
    <div class="endpoint"><div><span class="badge badge-patch">PATCH</span> <span class="path">/api/v1/rules/:id/toggle-enable</span></div><span class="desc">Bật / Tắt quy tắc</span></div>
    <div class="endpoint"><div><span class="badge badge-delete">DELETE</span> <span class="path">/api/v1/rules/:id</span></div><span class="desc">Xóa quy tắc</span></div>

    <h3 class="group-title">5. Yêu cầu Hỗ trợ (Support Tickets)</h3>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/tickets</span></div><span class="desc">Danh sách phiếu yêu cầu kỹ thuật</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/tickets</span></div><span class="desc">Gửi yêu cầu hỗ trợ mới (Phụ huynh)</span></div>
    <div class="endpoint"><div><span class="badge badge-put">PUT</span> <span class="path">/api/v1/tickets/:id</span></div><span class="desc">Xử lý tiến độ hỗ trợ (Nhân viên)</span></div>

    <h3 class="group-title">6. Sao lưu & Khôi phục (Backups & Snapshots)</h3>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/backups</span></div><span class="desc">Tạo bản Snapshot sao lưu dữ liệu</span></div>
    <div class="endpoint"><div><span class="badge badge-get">GET</span> <span class="path">/api/v1/backups</span></div><span class="desc">Danh sách các bản sao lưu</span></div>
    <div class="endpoint"><div><span class="badge badge-post">POST</span> <span class="path">/api/v1/backups/:id/restore</span></div><span class="desc">Khôi phục dữ liệu từ Snapshot</span></div>
  </div>
</body>
</html>
  `);
});

// Đăng ký API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/children', childRoutes);
app.use('/api/v1/rules', ruleRoutes);
app.use('/api/v1/tickets', ticketRoutes);
app.use('/api/v1/backups', backupRoutes);

// Xử lý lỗi 404
app.use((req, res) => {
  res.status(404).json({
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: `Đường dẫn ${req.method} ${req.originalUrl} không tồn tại trên hệ thống API`
    }
  });
});

// Middleware xử lý lỗi toàn cục
app.use(errorHandler);

// Khởi chạy server
app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`  🛡️ BẢO AN BACKEND WEB API SERVER IS RUNNING`);
  console.log(`  🔗 Local:   http://localhost:${PORT}`);
  console.log(`  📖 UI Docs: http://localhost:${PORT}/api-docs`);
  console.log(`=======================================================`);
});
