import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../services/email_service.dart';
import '../../theme/app_theme.dart';
import '../auth/email_config_dialog.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final user = appState.currentUser;
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Thông tin tài khoản'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar & Name Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: user.role.color.withAlpha(30),
                          child: Icon(user.role.icon, size: 40, color: user.role.color),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: user.role.color.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: user.role.color.withAlpha(80)),
                          ),
                          child: Text(
                            user.role.label,
                            style: TextStyle(color: user.role.color, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detail specs
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHI TIẾT TÀI KHOẢN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        const SizedBox(height: 12),
                        _buildInfoRow('Tên đăng nhập', user.username),
                        const Divider(height: 20),
                        _buildInfoRow('Email xác thực', user.email),
                        const Divider(height: 20),
                        _buildInfoRow('Số điện thoại', user.phone.isNotEmpty ? user.phone : 'Chưa cập nhật'),
                        const Divider(height: 20),
                        _buildInfoRow('Quyền truy cập', user.role.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Switch Role Demo Testing
                Card(
                  color: const Color(0xFFF0F7F3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('CHUYỂN NHANH VAI TRÒ (DÀNH CHO CHẤM ĐIỂM)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Chuyển đổi giao diện tức thì giữa Admin, Nhân viên và Khách hàng để kiểm tra phân quyền:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: user.role == UserRole.admin ? const Color(0xFFFFEBEE) : Colors.white,
                                  foregroundColor: const Color(0xFFD9534F),
                                  side: const BorderSide(color: Color(0xFFD9534F)),
                                ),
                                onPressed: () => appState.quickLogin(UserRole.admin),
                                child: const Text('Admin', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: user.role == UserRole.staff ? const Color(0xFFE8F5E9) : Colors.white,
                                  foregroundColor: const Color(0xFF2E7D32),
                                  side: const BorderSide(color: Color(0xFF2E7D32)),
                                ),
                                onPressed: () => appState.quickLogin(UserRole.staff),
                                child: const Text('Nhân viên', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: user.role == UserRole.customer ? const Color(0xFFE3F2FD) : Colors.white,
                                  foregroundColor: const Color(0xFF1976D2),
                                  side: const BorderSide(color: Color(0xFF1976D2)),
                                ),
                                onPressed: () => appState.quickLogin(UserRole.customer),
                                child: const Text('Khách hàng', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Service Config Card
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: EmailService().isConfigured ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      child: Icon(
                        Icons.mark_email_read_rounded,
                        color: EmailService().isConfigured ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    title: const Text('Cài đặt Gmail gửi OTP thực tế', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      EmailService().isDemoMode
                          ? 'Đang ở Chế độ Demo (Gửi OTP tức thì)'
                          : (EmailService().isConfigured
                              ? 'Đang dùng: ${EmailService().senderEmail}'
                              : 'Chưa cấu hình Mật khẩu ứng dụng Google'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const EmailConfigDialog(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Author info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('THÔNG TIN ĐỒ ÁN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        const Text('Ứng dụng: BẢO AN - Quản lý an toàn điện thoại trẻ em', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('Sinh viên thực hiện: NGUYỄN XUÂN ĐOÀN', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Mã sinh viên: 238600510 • Nhóm: DA', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Logout button
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                            onPressed: () {
                              Navigator.pop(ctx);
                              appState.logout();
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ],
    );
  }
}
