import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'email_config_dialog.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'khachhang');
  final _passwordController = TextEditingController(text: 'customer123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appState = AppState();
    final error = await appState.requestLogin(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (!mounted) return;
      final emailResult = appState.lastEmailResult;
      if (emailResult != null && emailResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📧 ${emailResult.message}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              emailResult?.errorMessage ?? 'Mã OTP của bạn là: ${appState.pendingOtp}',
            ),
            backgroundColor: emailResult != null ? AppColors.warning : AppColors.primary,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Cài đặt Gmail',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const EmailConfigDialog(),
                );
              },
            ),
          ),
        );
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const OtpScreen(isForRegister: false),
        ),
      );
    }
  }

  void _setDemoAccount(String username, String pass) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row with Settings button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.settings_outlined, size: 16, color: AppColors.primary),
                        label: const Text('Cài đặt Gmail gửi OTP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const EmailConfigDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // App Brand Logo
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'B',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BẢO AN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Text(
                    'Đồng hành cùng con trên không gian số',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Đăng nhập tài khoản',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Nhập thông tin đăng nhập và nhận mã OTP qua Gmail thực tế.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),

                  // Username / Email input
                  const Text(
                    'TÊN ĐĂNG NHẬP HOẶC EMAIL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên đăng nhập hoặc email',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập hoặc email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  const Text(
                    'MẬT KHẨU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (val.length < 6) {
                        return 'Mật khẩu phải từ 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Đang gửi mã OTP đến Gmail...'),
                            ],
                          )
                        : const Text('Tiếp tục & Gửi mã OTP về Gmail'),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Đăng ký bằng Gmail ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick test card
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'DÙNG THỬ NHANH THEO VAI TRÒ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Chọn vai trò để điền sẵn tài khoản hoặc đăng nhập trực tiếp:',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.admin_panel_settings, size: 16, color: Color(0xFFD9534F)),
                                label: const Text('Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFFFFEBEE),
                                onPressed: () => _setDemoAccount('admin', 'admin123'),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.badge, size: 16, color: Color(0xFF2E7D32)),
                                label: const Text('Nhân viên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFFE8F5E9),
                                onPressed: () => _setDemoAccount('staff', 'staff123'),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.family_restroom, size: 16, color: Color(0xFF1976D2)),
                                label: const Text('Khách hàng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFFE3F2FD),
                                onPressed: () => _setDemoAccount('khachhang', 'customer123'),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text('Đăng nhập trực tiếp (Bỏ qua OTP)'),
                            onPressed: () {
                              _showQuickLoginSheet(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'ĐỒ ÁN PHÁT TRIỂN ỨNG DỤNG DI ĐỘNG\nNGUYỄN XUÂN ĐOÀN · MSV: 238600510',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: Color(0xFFA0ACA5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Chọn quyền truy cập kiểm thử nhanh:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.admin_panel_settings, color: Color(0xFFD9534F)),
                ),
                title: const Text('Quản trị viên (Admin)'),
                subtitle: const Text('Vào trang quản trị, quản lý toàn bộ hệ thống & users'),
                onTap: () {
                  Navigator.pop(ctx);
                  AppState().quickLogin(UserRole.admin);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.badge, color: Color(0xFF2E7D32)),
                ),
                title: const Text('Nhân viên (Staff)'),
                subtitle: const Text('Vào Dashboard nhân viên, hỗ trợ & xử lý thiết bị'),
                onTap: () {
                  Navigator.pop(ctx);
                  AppState().quickLogin(UserRole.staff);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.family_restroom, color: Color(0xFF1976D2)),
                ),
                title: const Text('Khách hàng / Phụ huynh (Customer)'),
                subtitle: const Text('Vào trang theo dõi trẻ & giới hạn ứng dụng'),
                onTap: () {
                  Navigator.pop(ctx);
                  AppState().quickLogin(UserRole.customer);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
