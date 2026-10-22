# BẢO AN - HỆ THỐNG QUẢN LÝ AN TOÀN TRẺ EM TRÊN KHÔNG GIAN SỐ
**Đồ án Phát triển Ứng dụng Di động**
- **Sinh viên thực hiện**: Nguyễn Xuân Đoàn
- **Mã sinh viên**: 238600510
- **Nhóm**: DA

---

## 📂 1. CẤU TRÚC DỰ ÁN (MONOREPO)
Dự án được phân chia rõ ràng và chuyên nghiệp thành 2 phần độc lập: **Frontend** (Ứng dụng di động Flutter) và **Backend** (Máy chủ Web API):

```text
nguyenxuandoan/
├── frontend/                     # 📱 ỨNG DỤNG DI ĐỘNG (FLUTTER)
│   ├── android/                  # Cấu hình Android gốc
│   ├── lib/                      # Mã nguồn Dart chính
│   │   ├── models/               # Data Models (User, Child, AppRule, Ticket)
│   │   ├── screens/              # Giao diện (Admin, Staff, Customer, Auth, Features)
│   │   ├── services/             # Quản lý State & Dịch vụ gửi Gmail OTP
│   │   └── theme/                # Theme giao diện (Material 3)
│   ├── test/                     # Unit & Widget tests
│   ├── pubspec.yaml              # Cấu hình thư viện Flutter
│   └── README.md                 # Hướng dẫn chi tiết Frontend
│
├── backend/                      # 🖥️ MÁY CHỦ WEB API (NODE.JS & EXPRESS)
│   ├── src/
│   │   ├── data/                 # Cơ sở dữ liệu JSON Persistent
│   │   ├── middleware/           # Xác thực JWT (auth.js) & Xử lý lỗi
│   │   ├── routes/               # API Endpoints (Auth, Users, Children, Rules, Tickets, Backups)
│   │   ├── services/             # Dịch vụ Database & Snapshot Backup
│   │   └── server.js             # Entrypoint khởi chạy Express Server
│   ├── package.json              # Khai báo dependencies
│   ├── .env.example              # Cấu hình môi trường mẫu
│   └── README.md                 # Hướng dẫn chi tiết API & Endpoints
│
├── .gitignore                    # Bộ lọc Git chuẩn (bỏ qua build Flutter, node_modules)
├── run_on_device.bat             # Script 1-click cài đặt & chạy thẳng lên điện thoại Xiaomi
└── README.md                     # Tài liệu tổng quan hệ thống
```

---

## 🚀 2. HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### A. Khởi chạy Backend (Máy chủ Web API)
1. Mở terminal / PowerShell và di chuyển vào thư mục `backend`:
   ```bash
   cd backend
   ```
2. Cài đặt các thư viện (chỉ cần chạy lần đầu):
   ```bash
   npm install
   ```
3. Khởi chạy máy chủ:
   ```bash
   npm start
   # Hoặc chế độ tự động reload khi sửa code:
   npm run dev
   ```
4. Truy cập giao diện xem tài liệu API trực quan tại: **`http://localhost:5000/api-docs`**.

---

### B. Khởi chạy Frontend (Ứng dụng di động Flutter)

#### Cách 1: Chạy trực tiếp từ Android Studio
1. Mở thư mục **`frontend`** (hoặc mở thư mục gốc `nguyenxuandoan`) trong Android Studio.
2. Cấu hình chạy là file **`lib/main.dart`**.
3. Chọn thiết bị đích (điện thoại Xiaomi kết nối USB hoặc máy ảo Android).
4. Bấm nút **Run (Tam giác màu xanh)**.

#### Cách 2: Chạy 1-click bằng file `run_on_device.bat` (Khuyên dùng cho máy Xiaomi)
1. Bật chế độ "Gỡ lỗi qua USB" (USB Debugging) trên điện thoại Xiaomi.
2. Cắm cáp kết nối điện thoại với máy tính.
3. Nhấp đúp chuột vào file **`run_on_device.bat`** tại thư mục gốc. Script sẽ tự động biên dịch APK, nạp và khởi chạy ngay trên điện thoại!

---

## 🛡️ 3. CÁC TÍNH NĂNG CHÍNH ĐÃ HOÀN THIỆN
1. **Xác thực 2 lớp (2FA)**: Đăng nhập với Username/Password $\rightarrow$ Gửi mã xác thực OTP 6 số về Gmail hoặc dùng Chế độ Demo tiện lợi khi chấm bài.
2. **Phân quyền 3 vai trò (RBAC)**:
   - **Quản trị viên (Admin)**: Trung tâm điều khiển toàn hệ thống, quản lý danh sách tài khoản, khóa/mở khóa người dùng, giám sát an toàn.
   - **Nhân viên (Staff)**: Tiếp nhận và xử lý yêu cầu hỗ trợ (Support Tickets), theo dõi thiết bị cần cảnh báo.
   - **Khách hàng / Phụ huynh (Customer)**: Quản lý hồ sơ bé, cấu hình giới hạn thời gian sử dụng ứng dụng (YouTube, TikTok, Game), gửi yêu cầu trợ giúp.
3. **Đầy đủ chức năng CRUD**:
   - CRUD Người dùng (Users).
   - CRUD Hồ sơ trẻ em & Thiết bị (Children & Devices).
   - CRUD Giới hạn ứng dụng (App Rules).
   - CRUD Yêu cầu hỗ trợ (Support Tickets).
4. **Cơ chế Sao lưu Snapshot (Backups & Restore)**: Tạo snapshot dữ liệu theo chuẩn API thiết kế, có thể khôi phục (Merge/Replace) linh hoạt.

---

## 🔑 4. TÀI KHOẢN TRẢI NGHIỆM DÙNG THỬ
| Vai trò | Tên đăng nhập | Email | Mật khẩu | Mã OTP |
| :--- | :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin` | `admin.baoan.app@gmail.com` | `admin123` | Nhận qua Gmail hoặc xem trên màn hình |
| **Nhân viên (Staff)** | `staff` | `nhanvien.baoan.app@gmail.com` | `staff123` | Nhận qua Gmail hoặc xem trên màn hình |
| **Khách hàng (Customer)** | `khachhang` | `phuhuynh.baoan.app@gmail.com` | `customer123` | Nhận qua Gmail hoặc xem trên màn hình |
