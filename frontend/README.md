# BẢO AN - HỆ THỐNG QUẢN LÝ AN TOÀN TRẺ EM TRÊN KHÔNG GIAN SỐ
**Đồ án Phát triển Ứng dụng Di động**
- **Sinh viên thực hiện**: Nguyễn Xuân Đoàn
- **Mã sinh viên**: 238600510
- **Nhóm**: DA

---

## 1. YÊU CẦU & CHỨC NĂNG ĐÃ HOÀN THIỆN
### ✅ 1. Đăng ký tài khoản qua Gmail thực tế & Gửi mã OTP
- Form đăng ký đầy đủ: Họ tên, Tên đăng nhập, Email Gmail thực tế, Số điện thoại, Mật khẩu & Nhập lại mật khẩu.
- Chọn vai trò ban đầu: Khách hàng (Phụ huynh), Nhân viên kỹ thuật, hoặc Quản trị viên (Admin).
- Kiểm tra tính hợp lệ: Định dạng email Gmail, độ dài mật khẩu $\ge 6$, xác nhận mật khẩu, không trùng lặp tài khoản.
- **Hỗ trợ 2 chế độ gửi OTP linh hoạt**:
  1. **Chế độ Demo (Mặc định)**: Mã OTP sinh ra và hoạt động ngay tức thì, hiển thị thông báo mô phỏng thành công, không bị chặn bởi bảo mật Google, cực kỳ thuận tiện cho việc chấm bài.
  2. **Chế độ gửi Gmail thật qua SMTP**: Kết nối trực tiếp máy chủ Google `smtp.gmail.com` để gửi email HTML thực tế về hộp thư Gmail người nhận.

### ✅ 2. Đăng nhập 2 lớp (Tên đăng nhập + Mật khẩu + OTP)
- Đăng nhập an toàn với Username (hoặc Email) và Mật khẩu.
- Chuyển hướng đến màn hình xác thực OTP 2 lớp (Two-Factor Authentication).
- Gửi mã xác thực OTP 6 số về Gmail đã đăng ký của tài khoản.
- Có nút "Gửi lại mã OTP vào Gmail" và nút "Điền mã này" nếu muốn kiểm thử nhanh.
- Đã xử lý triệt để lỗi tràn giao diện (`RIGHT OVERFLOWED BY 53 PIXELS`) trên màn hình điện thoại nhỏ.
- Nhập chính xác mã OTP $\rightarrow$ Điều hướng thẳng đến màn hình phù hợp theo vai trò (Role).

### ✅ 3. Phân quyền người dùng (Role-Based Access Control)
- **Quản trị viên (Admin)**:
  - Truy cập **Trung tâm Quản trị (Admin Console)**.
  - Xem thống kê toàn hệ thống: Tổng tài khoản, Admin, Nhân viên, Khách hàng, Trẻ em & thiết bị.
  - **Quản trị người dùng**: Thêm mới, tìm kiếm, lọc theo vai trò, chỉnh sửa thông tin, khóa / mở khóa tài khoản, xóa tài khoản.
  - Quản trị toàn bộ thiết bị và danh mục quy tắc an toàn.
- **Nhân viên (Staff)**:
  - Truy cập **Dashboard Nhân viên (Staff Dashboard)**.
  - Theo dõi danh sách thiết bị được phân công giám sát.
  - Xử lý các thiết bị có trạng thái "Cần chú ý / Cảnh báo", chuyển đổi trạng thái an toàn.
  - Tiếp nhận và xử lý các Yêu cầu hỗ trợ (Support Tickets) từ Khách hàng / Phụ huynh (Chờ xử lý $\rightarrow$ Đang hỗ trợ $\rightarrow$ Đã hoàn tất).
  - Quản lý quy tắc ứng dụng cho trẻ em.
- **Khách hàng / Phụ huynh (Customer / Parent)**:
  - Truy cập **Góc gia đình Bảo An**.
  - Xem tổng quan các thiết bị của con em mình, thời gian sử dụng hôm nay.
  - **Quản lý Hồ sơ Trẻ**: Thêm bé mới, sửa thông tin, đổi trạng thái an toàn, xóa hồ sơ.
  - **Quản lý Giới hạn Ứng dụng**: Thêm quy tắc giới hạn thời gian (YouTube, TikTok, Roblox...), bật/tắt giới hạn linh hoạt, sửa/xóa quy tắc.
  - Gửi yêu cầu hỗ trợ trực tiếp tới nhân viên.
- **Chuyển đổi vai trò nhanh (Quick Role Switcher)**:
  - Tại tab Tài khoản và màn hình Đăng nhập có sẵn các nút bấm chuyển đổi nhanh giữa Admin, Nhân viên, Khách hàng mà không cần phải thoát ra nhập lại mật khẩu nhiều lần.

### ✅ 4. Các chức năng CRUD đầy đủ
1. **CRUD Người dùng (Users)**: Create, Read (tìm kiếm & lọc), Update, Delete + Khóa/Mở khóa.
2. **CRUD Hồ sơ Trẻ em & Thiết bị (Children & Devices)**: Create, Read, Update, Delete + Đổi trạng thái An toàn/Cảnh báo.
3. **CRUD Giới hạn Ứng dụng (App Rules)**: Create, Read, Update, Delete + Bật/Tắt (Toggle Switch).
4. **CRUD Yêu cầu Hỗ trợ (Support Tickets)**: Create, Read, Update (chuyển trạng thái xử lý), Delete.

---

## 2. CÁCH SỬ DỤNG CHỨC NĂNG GỬI OTP GMAIL
Bấm vào nút **`⚙️ Cài đặt Gmail gửi OTP`** (ở góc trên màn hình Đăng nhập, Đăng ký, hoặc tab Tài khoản):
- **Cách 1: Dùng Chế độ Demo (Khuyên dùng khi chấm bài, test nhanh)**:
  - Công tắc "Chế độ Demo" được bật sẵn.
  - Bấm "Gửi thử" $\rightarrow$ Báo thành công ngay lập tức!
  - Khi Đăng ký / Đăng nhập, mã OTP sẽ hiển thị trên màn hình và có nút "Điền mã này", không bao giờ gặp lỗi xác thực của Google.
- **Cách 2: Gửi thư thật vào hòm thư Gmail của bạn**:
  - Gạt tắt công tắc "Chế độ Demo".
  - Nhập địa chỉ Gmail của bạn và **Mật khẩu ứng dụng 16 ký tự** (tạo tại: https://myaccount.google.com/apppasswords sau khi bật Xác minh 2 bước trên Google).
  - Bấm "Gửi thử" và "Lưu cấu hình".

---

## 3. TÀI KHOẢN DÙNG THỬ CÓ SẴN
| Vai trò | Tên đăng nhập | Email | Mật khẩu | Mã OTP |
| :--- | :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin` | `admin.baoan.app@gmail.com` | `admin123` | Nhận qua Gmail hoặc xem trên màn hình |
| **Nhân viên (Staff)** | `staff` | `nhanvien.baoan.app@gmail.com` | `staff123` | Nhận qua Gmail hoặc xem trên màn hình |
| **Khách hàng (Customer)** | `khachhang` | `phuhuynh.baoan.app@gmail.com` | `customer123` | Nhận qua Gmail hoặc xem trên màn hình |

---

## 4. CÁCH CHẠY ỨNG DỤNG
### Cách 1: Chạy trực tiếp từ Android Studio
1. Mở thư mục `nguyenxuandoan` trong Android Studio.
2. Tại thanh công cụ trên cùng, cấu hình chạy là **`main.dart`**.
3. Chọn thiết bị đích là máy thật **Xiaomi** hoặc máy ảo.
4. Bấm nút **Run (Tam giác màu xanh)** để chạy ứng dụng.

### Cách 2: Chạy bằng file `run_on_device.bat` (Khuyên dùng cho máy Xiaomi)
1. Cắm cáp điện thoại Xiaomi vào máy tính (bật USB Debugging).
2. Nhấp đúp chuột vào file **`run_on_device.bat`** tại thư mục gốc.
3. Hệ thống sẽ tự động cài đặt thẳng lên điện thoại và khởi chạy ứng dụng!
