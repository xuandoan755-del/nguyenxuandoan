# 🛡️ BẢO AN - BACKEND WEB API SERVER
**Hệ thống Quản lý An toàn Trẻ em trên Không gian số**
- **Sinh viên thực hiện**: Nguyễn Xuân Đoàn
- **Mã sinh viên**: 238600510
- **Nhóm**: DA

---

## 1. Giới thiệu
Đây là máy chủ RESTful Web API phục vụ toàn bộ chức năng cho ứng dụng di động **Bảo An (Frontend Flutter)**, bao gồm:
- Xác thực 2 lớp (Tên đăng nhập / Mật khẩu + OTP 6 số).
- Phân quyền người dùng (Role-Based Access Control): Quản trị viên (Admin), Nhân viên kỹ thuật (Staff), Khách hàng/Phụ huynh (Customer).
- CRUD Quản lý người dùng, khóa/mở khóa tài khoản.
- CRUD Quản lý hồ sơ trẻ em và thiết bị giám sát.
- CRUD Quản lý quy tắc ứng dụng (giới hạn thời gian, khóa app, bật/tắt).
- CRUD Quản lý phiếu yêu cầu hỗ trợ (Support Tickets).
- Sao lưu dữ liệu Snapshot & Khôi phục (Backup & Restore) theo thiết kế hệ thống.

---

## 2. Hướng dẫn cài đặt và khởi chạy

### Yêu cầu:
- Node.js version 18 trở lên (khuyên dùng Node.js 20 LTS hoặc mới nhất).

### Các bước chạy máy chủ:
```bash
# 1. Di chuyển vào thư mục backend
cd backend

# 2. Cài đặt các thư viện cần thiết
npm install

# 3. Khởi chạy máy chủ (Development)
npm run dev
# Hoặc chạy thông thường:
npm start
```

Khi chạy thành công:
- **Địa chỉ máy chủ**: `http://localhost:5000`
- **Giao diện tra cứu API (Interactive Docs)**: `http://localhost:5000/api-docs`

---

## 3. Danh sách Endpoints chính (`/api/v1`)

| Nhóm chức năng | Phương thức | Đường dẫn API | Mô tả |
| :--- | :--- | :--- | :--- |
| **Xác thực (Auth)** | `POST` | `/api/v1/auth/register` | Đăng ký tài khoản mới & gửi mã OTP |
| | `POST` | `/api/v1/auth/login` | Đăng nhập bước 1 & gửi OTP 2 lớp |
| | `POST` | `/api/v1/auth/verify-otp` | Xác thực OTP & cấp JWT Token |
| | `GET` | `/api/v1/auth/me` | Lấy thông tin tài khoản hiện tại |
| **Người dùng (Admin)** | `GET` | `/api/v1/users` | Danh sách tài khoản hệ thống |
| | `POST` | `/api/v1/users` | Thêm tài khoản mới |
| | `PUT` | `/api/v1/users/:id` | Cập nhật thông tin tài khoản |
| | `PATCH` | `/api/v1/users/:id/toggle-lock` | Khóa / Mở khóa tài khoản |
| | `DELETE` | `/api/v1/users/:id` | Xóa tài khoản |
| **Hồ sơ trẻ (Children)** | `GET` | `/api/v1/children` | Danh sách trẻ em |
| | `POST` | `/api/v1/children` | Tạo hồ sơ trẻ mới |
| | `PUT` | `/api/v1/children/:id` | Cập nhật hồ sơ trẻ |
| | `PATCH` | `/api/v1/children/:id/toggle-safe`| Đổi trạng thái An toàn / Cảnh báo |
| | `DELETE` | `/api/v1/children/:id` | Xóa hồ sơ trẻ |
| **Quy tắc (App Rules)** | `GET` | `/api/v1/rules` | Danh sách quy tắc giới hạn app |
| | `POST` | `/api/v1/rules` | Thêm quy tắc mới |
| | `PATCH` | `/api/v1/rules/:id/toggle-enable`| Bật / Tắt quy tắc |
| | `DELETE` | `/api/v1/rules/:id` | Xóa quy tắc |
| **Hỗ trợ (Tickets)** | `GET` | `/api/v1/tickets` | Danh sách yêu cầu hỗ trợ |
| | `POST` | `/api/v1/tickets` | Gửi yêu cầu hỗ trợ mới |
| | `PUT` | `/api/v1/tickets/:id` | Cập nhật tiến độ hỗ trợ |
| **Sao lưu (Backups)** | `POST` | `/api/v1/backups` | Tạo snapshot sao lưu |
| | `GET` | `/api/v1/backups` | Danh sách snapshot |
| | `POST` | `/api/v1/backups/:id/restore` | Khôi phục snapshot |

---

## 4. Tài khoản mẫu có sẵn
- **Admin**: `admin` / `admin123`
- **Staff**: `staff` / `staff123`
- **Customer**: `khachhang` / `customer123`
