import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'email_config_dialog.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu nhập lại không khớp!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final appState = AppState();
    final error = await appState.requestRegister(
      fullName: _fullNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
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
          builder: (_) => const OtpScreen(isForRegister: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt Gmail gửi OTP',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const EmailConfigDialog(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sử dụng địa chỉ Gmail có thật để nhận mã OTP xác thực kích hoạt tài khoản.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Role Selector Chips
                const Text(
                  'VAI TRÒ TRUY CẬP HỆ THỐNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: Icon(Icons.family_restroom, size: 16, color: _selectedRole == UserRole.customer ? Colors.white : AppColors.primary),
                        label: const Text('Khách hàng'),
                        selected: _selectedRole == UserRole.customer,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = UserRole.customer);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: Icon(Icons.badge, size: 16, color: _selectedRole == UserRole.staff ? Colors.white : AppColors.primary),
                        label: const Text('Nhân viên'),
                        selected: _selectedRole == UserRole.staff,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = UserRole.staff);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: Icon(Icons.admin_panel_settings, size: 16, color: _selectedRole == UserRole.admin ? Colors.white : AppColors.primary),
                        label: const Text('Admin'),
                        selected: _selectedRole == UserRole.admin,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = UserRole.admin);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Name
                const Text(
                  'HỌ VÀ TÊN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Nguyễn Văn An',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 14),

                // Username
                const Text(
                  'TÊN ĐĂNG NHẬP',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: nguyenvanan',
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                  ),
                  validator: (val) => val == null || val.trim().length < 3 ? 'Tên đăng nhập từ 3 ký tự' : null,
                ),
                const SizedBox(height: 14),

                // Email
                const Text(
                  'ĐỊA CHỈ GMAIL (NHẬN MÃ OTP THẬT)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'ban.nguyen@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Vui lòng nhập Gmail';
                    final v = val.trim().toLowerCase();
                    if (!v.contains('@') || !v.contains('.')) return 'Email không đúng định dạng';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                const Text(
                  'SỐ ĐIỆN THOẠI',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: 0912345678',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                ),
                const SizedBox(height: 14),

                // Password
                const Text(
                  'MẬT KHẨU',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Tối thiểu 6 ký tự',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 14),

                // Confirm Password
                const Text(
                  'XÁC NHẬN MẬT KHẨU',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu',
                    prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Vui lòng xác nhận mật khẩu' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Đang gửi mã OTP đến Gmail...'),
                          ],
                        )
                      : const Text('Tiếp tục & Gửi mã OTP về Gmail'),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đã có tài khoản? Quay lại đăng nhập'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
