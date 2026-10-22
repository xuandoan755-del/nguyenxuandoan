import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SendEmailResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  SendEmailResult({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

class EmailService extends ChangeNotifier {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;

  EmailService._internal();

  // Cấu hình tài khoản Gmail gửi email OTP
  String _senderEmail = '';
  String _senderAppPassword = '';
  String _senderName = 'Hệ thống Bảo An';
  bool _isDemoMode = true; // Mặc định bật chế độ demo để tránh lỗi xác thực khi người dùng chưa có App Password

  String get senderEmail => _senderEmail;
  String get senderAppPassword => _senderAppPassword;
  String get senderName => _senderName;
  bool get isDemoMode => _isDemoMode;

  bool get isConfigured => _senderEmail.isNotEmpty && _senderAppPassword.isNotEmpty;

  void setDemoMode(bool value) {
    _isDemoMode = value;
    notifyListeners();
  }

  void updateConfig({
    required String email,
    required String appPassword,
    String? name,
    bool? demoMode,
  }) {
    _senderEmail = email.trim();
    // Loại bỏ khoảng trắng nếu người dùng copy từ Google (Google hiển thị 4 nhóm 4 chữ cái)
    _senderAppPassword = appPassword.replaceAll(' ', '').trim();
    if (name != null && name.trim().isNotEmpty) {
      _senderName = name.trim();
    }
    if (demoMode != null) {
      _isDemoMode = demoMode;
    } else if (isConfigured) {
      _isDemoMode = false;
    }
    notifyListeners();
  }

  /// Gửi email OTP thực tế đến địa chỉ Gmail của người nhận
  Future<SendEmailResult> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
    String recipientName = 'Quý khách',
    bool isForRegister = false,
  }) async {
    final cleanRecipient = recipientEmail.trim();

    // Nếu đang ở chế độ demo mô phỏng: trả về thành công ngay lập tức
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return SendEmailResult(
        success: true,
        message: 'Mã OTP [$otpCode] đã được gửi đến $cleanRecipient (Mô phỏng thành công)',
      );
    }

    if (!isConfigured) {
      return SendEmailResult(
        success: false,
        errorMessage: 'Chưa cấu hình Mật khẩu ứng dụng Google (App Password 16 ký tự). '
            'Vui lòng nhập tài khoản Gmail của bạn hoặc bật Chế độ Demo trong phần Cài đặt.',
      );
    }

    try {
      // Kết nối trực tiếp đến máy chủ Google Gmail SMTP
      final smtpServer = gmail(_senderEmail, _senderAppPassword);

      final subject = isForRegister
          ? '[$otpCode] Mã OTP kích hoạt tài khoản Bảo An'
          : '[$otpCode] Mã OTP đăng nhập ứng dụng Bảo An';

      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Mã xác thực OTP Bảo An</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f4f7f4; margin: 0; padding: 24px; color: #203229;">
  <div style="max-width: 520px; margin: 0 auto; background: #ffffff; border-radius: 16px; border: 1px solid #e0e8e2; overflow: hidden; box-shadow: 0 4px 16px rgba(0,0,0,0.06);">
    <div style="background: linear-gradient(135deg, #24745d, #174d3f); padding: 28px 24px; text-align: center;">
      <h1 style="color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px;">BẢO AN</h1>
      <p style="color: #d5e8de; margin: 6px 0 0; font-size: 13px;">Hệ thống Quản lý & Bảo vệ Trẻ em trên Không gian số</p>
    </div>
    <div style="padding: 28px 24px;">
      <p style="font-size: 15px; margin-top: 0;">Xin chào <strong>$recipientName</strong>,</p>
      <p style="font-size: 14px; color: #52665a; line-height: 1.6;">
        Bạn đang thực hiện <strong>${isForRegister ? 'đăng ký tài khoản mới' : 'đăng nhập vào hệ thống'}</strong> trên ứng dụng Bảo An. 
        Dưới đây là mã xác thực OTP dùng một lần của bạn:
      </p>
      
      <div style="background-color: #eaf4ee; border: 2px dashed #24745d; border-radius: 12px; padding: 18px; text-align: center; margin: 24px 0;">
        <span style="font-size: 34px; font-weight: 800; letter-spacing: 8px; color: #174d3f; font-family: monospace;">$otpCode</span>
      </div>

      <div style="background-color: #fff8e1; border-left: 4px solid #f57c00; padding: 12px 16px; border-radius: 4px; margin-bottom: 20px;">
        <p style="margin: 0; font-size: 13px; color: #8d4f00;">
          ⚠️ <strong>Lưu ý:</strong> Mã OTP có hiệu lực trong vòng <strong>5 phút</strong>. Tuyệt đối không chia sẻ mã này cho bất kỳ ai.
        </p>
      </div>

      <p style="font-size: 13px; color: #7c8981; line-height: 1.5;">
        Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc liên hệ với bộ phận hỗ trợ kỹ thuật của Bảo An.
      </p>
    </div>
    <div style="background-color: #f9fbf9; padding: 16px 24px; text-align: center; border-top: 1px solid #eef2ef;">
      <p style="margin: 0; font-size: 11px; color: #9aa8a0;">
        Đồ án Phát triển Ứng dụng Di động · Nhóm DA<br>
        Sinh viên thực hiện: <strong>Nguyễn Xuân Đoàn</strong> (MSV: 238600510)
      </p>
    </div>
  </div>
</body>
</html>
''';

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(cleanRecipient)
        ..subject = subject
        ..html = htmlContent;

      await send(message, smtpServer);

      return SendEmailResult(
        success: true,
        message: 'Đã gửi mã OTP thành công đến Gmail: $cleanRecipient',
      );
    } on MailerException catch (e) {
      String detail = '';
      for (var p in e.problems) {
        detail += '${p.msg} ';
      }
      if (detail.isEmpty || detail.contains('535') || detail.toLowerCase().contains('password') || detail.toLowerCase().contains('credential')) {
        detail = 'Sai tài khoản hoặc Mật khẩu ứng dụng (Google mã 535). Hãy dùng mã 16 ký tự từ trang myaccount.google.com/apppasswords.';
      }
      return SendEmailResult(
        success: false,
        errorMessage: 'Lỗi xác thực Google: $detail',
      );
    } catch (e) {
      return SendEmailResult(
        success: false,
        errorMessage: 'Không thể kết nối đến máy chủ Google: $e (Vui lòng kiểm tra lại kết nối mạng hoặc bật Chế độ Demo).',
      );
    }
  }
}
