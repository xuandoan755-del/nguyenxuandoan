import 'package:flutter/material.dart';
import '../../services/email_service.dart';
import '../../theme/app_theme.dart';

class EmailConfigDialog extends StatefulWidget {
  const EmailConfigDialog({super.key});

  @override
  State<EmailConfigDialog> createState() => _EmailConfigDialogState();
}

class _EmailConfigDialogState extends State<EmailConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailCtrl;
  late TextEditingController _appPassCtrl;
  late TextEditingController _nameCtrl;
  final _testEmailCtrl = TextEditingController();

  late bool _isDemoMode;
  bool _obscurePass = true;
  bool _isTesting = false;
  String? _testMessage;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final service = EmailService();
    _isDemoMode = service.isDemoMode;
    _emailCtrl = TextEditingController(text: service.senderEmail);
    _appPassCtrl = TextEditingController(text: service.senderAppPassword);
    _nameCtrl = TextEditingController(text: service.senderName);
    _testEmailCtrl.text = service.senderEmail.isNotEmpty ? service.senderEmail : 'doan.nguyen@gmail.com';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _appPassCtrl.dispose();
    _nameCtrl.dispose();
    _testEmailCtrl.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (!_isDemoMode && !_formKey.currentState!.validate()) return;

    EmailService().updateConfig(
      email: _emailCtrl.text,
      appPassword: _appPassCtrl.text,
      name: _nameCtrl.text,
      demoMode: _isDemoMode,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDemoMode
              ? 'Đã bật Chế độ Mô phỏng gửi OTP thành công!'
              : 'Đã lưu cấu hình gửi Gmail thực tế thành công!',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _handleTestSend() async {
    final target = _testEmailCtrl.text.trim();
    if (target.isEmpty || !target.contains('@')) {
      setState(() {
        _testMessage = 'Vui lòng nhập địa chỉ Gmail nhận thử nghiệm hợp lệ!';
        _testSuccess = false;
      });
      return;
    }

    if (!_isDemoMode && (_emailCtrl.text.isEmpty || _appPassCtrl.text.isEmpty)) {
      setState(() {
        _testMessage = 'Vui lòng nhập Email người gửi và Mật khẩu ứng dụng 16 ký tự!';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    EmailService().updateConfig(
      email: _emailCtrl.text,
      appPassword: _appPassCtrl.text,
      name: _nameCtrl.text,
      demoMode: _isDemoMode,
    );

    final result = await EmailService().sendOtpEmail(
      recipientEmail: target,
      otpCode: '888999',
      recipientName: 'Bạn (Thử nghiệm)',
      isForRegister: false,
    );

    setState(() {
      _isTesting = false;
      _testSuccess = result.success;
      _testMessage = result.success
          ? (_isDemoMode
              ? 'Mô phỏng gửi thành công đến $target! Hệ thống đã sẵn sàng.'
              : 'Đã gửi thành công vào hộp thư Gmail: $target!')
          : (result.errorMessage ?? 'Gửi thất bại.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Row(
        children: [
          Icon(Icons.mail_lock_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Cấu hình gửi Gmail OTP',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Toggle: Demo Mode
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isDemoMode ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isDemoMode ? const Color(0xFFA5D6A7) : const Color(0xFFFFB74D),
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      _isDemoMode ? 'Chế độ Demo (Không cần mật khẩu)' : 'Chế độ gửi Gmail Thật qua SMTP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isDemoMode ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                    subtitle: Text(
                      _isDemoMode
                          ? 'Mã OTP hoạt động tức thì, rất tiện cho việc kiểm tra và chấm điểm.'
                          : 'Yêu cầu nhập Gmail và Mật khẩu ứng dụng 16 ký tự của Google.',
                      style: const TextStyle(fontSize: 11),
                    ),
                    value: _isDemoMode,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _isDemoMode = val;
                        _testMessage = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 14),

                if (!_isDemoMode) ...[
                  // Instructions Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4EE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withAlpha(60)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HƯỚNG DẪN LẤY MẬT KHẨU ỨNG DỤNG GMAIL:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryDark),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '1. Bật "Xác minh 2 bước" trong tài khoản Google.\n'
                          '2. Vào: myaccount.google.com/apppasswords\n'
                          '3. Tạo mật khẩu ứng dụng và copy mã 16 ký tự dán vào bên dưới.',
                          style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sender Gmail
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Gmail người gửi (Tài khoản Google của bạn)',
                      hintText: 'gmail_cua_ban@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'Vui lòng nhập Gmail hợp lệ' : null,
                  ),
                  const SizedBox(height: 12),

                  // App Password
                  TextFormField(
                    controller: _appPassCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu ứng dụng (App Password 16 ký tự)',
                      hintText: 'xxxx xxxx xxxx xxxx',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) => v == null || v.replaceAll(' ', '').trim().length < 10
                        ? 'Nhập mật khẩu ứng dụng 16 ký tự từ Google'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Sender Display Name
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị người gửi',
                      hintText: 'Hệ thống Bảo An',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                ],

                const Divider(height: 24),

                // Test Send Section
                const Text(
                  'KIỂM TRA GỬI THỬ NGHIỆM',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _testEmailCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nhập Gmail nhận thử',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: _isTesting ? null : _handleTestSend,
                      child: _isTesting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Gửi thử', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                if (_testMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _testSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _testMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        color: _testSuccess ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ElevatedButton(
          onPressed: _saveConfig,
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 42)),
          child: const Text('Lưu cấu hình'),
        ),
      ],
    );
  }
}
