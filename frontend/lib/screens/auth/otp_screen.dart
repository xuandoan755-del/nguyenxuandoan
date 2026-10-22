import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'email_config_dialog.dart';

class OtpScreen extends StatefulWidget {
  final bool isForRegister;
  const OtpScreen({super.key, required this.isForRegister});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _appState = AppState();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo OTP code if present so the user can also test offline or without SMTP setup
    if (_appState.pendingOtp != null) {
      _otpController.text = _appState.pendingOtp!;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số mã OTP!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;
    if (widget.isForRegister) {
      success = _appState.verifyRegisterOtp(code);
    } else {
      success = _appState.verifyLoginOtp(code);
    }

    setState(() => _isLoading = false);

    if (success) {
      // Pop until root so main app switches to logged in state
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isForRegister
                ? 'Đăng ký tài khoản thành công! Chào mừng ${_appState.currentUser?.fullName}'
                : 'Đăng nhập thành công! Chào mừng ${_appState.currentUser?.fullName}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã OTP không chính xác hoặc đã hết hạn! Vui lòng thử lại.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    final result = await _appState.resendOtp();
    setState(() => _isResending = false);

    if (_appState.pendingOtp != null) {
      setState(() {
        _otpController.text = _appState.pendingOtp!;
      });
    }

    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📧 ${result.message}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Đã tạo mã OTP mới: ${_appState.pendingOtp}'),
          backgroundColor: AppColors.warning,
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
  }

  @override
  Widget build(BuildContext context) {
    final targetEmail = _appState.pendingEmail ?? 'email của bạn';
    final currentOtp = _appState.pendingOtp ?? '123456';
    final emailResult = _appState.lastEmailResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xác minh OTP qua Gmail'),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(80), width: 2),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kiểm tra hộp thư Gmail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
                  children: [
                    const TextSpan(text: 'Hệ thống đã gửi mã OTP 6 chữ số đến địa chỉ Gmail:\n'),
                    TextSpan(
                      text: targetEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Email dispatch status card
              if (emailResult != null && emailResult.success)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Đã gửi thành công đến Gmail $targetEmail! Vui lòng kiểm tra Hộp thư đến (hoặc thư mục Spam/Rác).',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              emailResult?.errorMessage ??
                                  'Chưa cấu hình Mật khẩu ứng dụng Gmail gửi thư. Bạn có thể cấu hình bằng nút ⚙️ góc trên.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF8D4F00), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Mã OTP hỗ trợ: $currentOtp',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpController.text = currentOtp;
                              });
                            },
                            child: const Text('Điền mã này'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // OTP Input
              const Text(
                'MÃ XÁC THỰC (6 CHỮ SỐ)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                  color: AppColors.primaryDark,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: TextStyle(letterSpacing: 12, color: Color(0xFFCBD6CE)),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.isForRegister ? 'Hoàn tất Đăng ký' : 'Xác nhận Đăng nhập'),
              ),
              const SizedBox(height: 16),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text('Chưa nhận được email? ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  TextButton(
                    onPressed: _isResending ? null : _handleResend,
                    child: _isResending
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Gửi lại mã OTP vào Gmail'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
