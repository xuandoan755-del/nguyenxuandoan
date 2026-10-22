import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/rule_model.dart';
import '../models/ticket_model.dart';
import 'email_service.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;

  AppState._internal() {
    _initSeedData();
  }

  // --- Auth state ---
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Pending OTP data
  String? _pendingOtp;
  String? _pendingEmail;
  UserModel? _pendingUser; // for registration
  UserModel? _pendingLoginUser; // for login
  SendEmailResult? _lastEmailResult;
  String? get pendingEmail => _pendingEmail;
  String? get pendingOtp => _pendingOtp;
  SendEmailResult? get lastEmailResult => _lastEmailResult;

  // --- Data lists ---
  final List<UserModel> _users = [];
  final List<ChildProfile> _children = [];
  final List<AppRule> _rules = [];
  final List<SupportTicket> _tickets = [];

  List<UserModel> get users => List.unmodifiable(_users);
  List<ChildProfile> get children => List.unmodifiable(_children);
  List<AppRule> get rules => List.unmodifiable(_rules);
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);

  void _initSeedData() {
    // 1. Initial Users
    _users.addAll([
      UserModel(
        id: 'u_admin',
        username: 'admin',
        email: 'admin.baoan.app@gmail.com',
        password: 'admin123',
        fullName: 'Quản trị viên Hệ thống',
        phone: '0901234567',
        role: UserRole.admin,
      ),
      UserModel(
        id: 'u_staff',
        username: 'staff',
        email: 'nhanvien.baoan.app@gmail.com',
        password: 'staff123',
        fullName: 'Kỹ thuật viên Hỗ trợ',
        phone: '0912345678',
        role: UserRole.staff,
      ),
      UserModel(
        id: 'u_customer',
        username: 'khachhang',
        email: 'phuhuynh.baoan.app@gmail.com',
        password: 'customer123',
        fullName: 'Phụ huynh Nguyễn Văn Nam',
        phone: '0987654321',
        role: UserRole.customer,
      ),
    ]);

    // 2. Initial Children
    _children.addAll([
      ChildProfile(
        id: 'c_1',
        ownerId: 'u_customer',
        name: 'Nguyễn Minh Khang',
        age: 10,
        device: 'iPhone 12 mini',
        dailyUsageMinutes: 134,
        isSafe: true,
        notes: 'Chỉ cho xem video giáo dục trong tuần',
      ),
      ChildProfile(
        id: 'c_2',
        ownerId: 'u_customer',
        name: 'Nguyễn Bảo Ngọc',
        age: 8,
        device: 'Samsung Galaxy A54',
        dailyUsageMinutes: 198,
        isSafe: false,
        notes: 'Đang dùng quá thời gian quy định!',
      ),
      ChildProfile(
        id: 'c_3',
        ownerId: 'u_customer',
        name: 'Trần Gia Huy',
        age: 12,
        device: 'Xiaomi Redmi Note 13',
        dailyUsageMinutes: 85,
        isSafe: true,
        notes: 'Học online và giải trí cuối tuần',
      ),
    ]);

    // 3. Initial Rules
    _rules.addAll([
      AppRule(
        id: 'r_1',
        childId: 'c_1',
        appName: 'YouTube Kids',
        limitMinutes: 45,
        period: 'Mỗi ngày',
        isEnabled: true,
      ),
      AppRule(
        id: 'r_2',
        childId: 'c_1',
        appName: 'TikTok',
        limitMinutes: 30,
        period: 'Cuối tuần',
        isEnabled: true,
      ),
      AppRule(
        id: 'r_3',
        childId: 'c_2',
        appName: 'Roblox Games',
        limitMinutes: 60,
        period: 'Cuối tuần',
        isEnabled: true,
      ),
      AppRule(
        id: 'r_4',
        childId: 'c_2',
        appName: 'Facebook / Messenger',
        limitMinutes: 20,
        period: 'Mỗi ngày',
        isEnabled: false,
      ),
    ]);

    // 4. Initial Tickets
    _tickets.addAll([
      SupportTicket(
        id: 't_1',
        customerId: 'u_customer',
        customerName: 'Nguyễn Văn Nam',
        title: 'Mở rộng thời gian cuối tuần',
        content: 'Tôi muốn tăng thời gian YouTube cuối tuần lên 60 phút cho bé Minh Khang.',
        status: TicketStatus.pending,
      ),
      SupportTicket(
        id: 't_2',
        customerId: 'u_customer',
        customerName: 'Nguyễn Văn Nam',
        title: 'Cảnh báo thiết bị Samsung A54',
        content: 'Bé Bảo Ngọc dùng quá thời gian quy định, cần nhân viên hỗ trợ khóa máy tạm thời.',
        status: TicketStatus.inProgress,
        assignedStaffId: 'u_staff',
      ),
    ]);
  }

  // ==========================================
  // AUTHENTICATION LOGIC (EMAIL, PASSWORD, OTP)
  // ==========================================

  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Request Login: Check username/password, then generate OTP and send real Gmail
  Future<String?> requestLogin(String usernameOrEmail, String password) async {
    final input = usernameOrEmail.trim().toLowerCase();
    final user = _users.firstWhere(
      (u) => (u.username.toLowerCase() == input || u.email.toLowerCase() == input) && u.password == password,
      orElse: () => UserModel(
        id: '',
        username: '',
        email: '',
        password: '',
        fullName: '',
        phone: '',
        role: UserRole.customer,
      ),
    );

    if (user.id.isEmpty) {
      return 'Tên đăng nhập hoặc mật khẩu không chính xác!';
    }

    if (!user.isActive) {
      return 'Tài khoản của bạn hiện đang bị khóa. Vui lòng liên hệ Admin!';
    }

    // Generate OTP
    _pendingLoginUser = user;
    _pendingEmail = user.email;
    _pendingOtp = _generateOtp();
    notifyListeners();

    // Send real OTP email
    _lastEmailResult = await EmailService().sendOtpEmail(
      recipientEmail: user.email,
      otpCode: _pendingOtp!,
      recipientName: user.fullName,
      isForRegister: false,
    );
    notifyListeners();

    return null; // success -> proceed to OTP
  }

  /// Verify Login OTP
  bool verifyLoginOtp(String enteredOtp) {
    if (_pendingLoginUser != null && _pendingOtp == enteredOtp.trim()) {
      _currentUser = _pendingLoginUser;
      _pendingLoginUser = null;
      _pendingOtp = null;
      _pendingEmail = null;
      _lastEmailResult = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Request Registration via Email: Validate & generate OTP, then send real Gmail
  Future<String?> requestRegister({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanUsername = username.trim().toLowerCase();

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'Email không hợp lệ!';
    }

    if (cleanUsername.length < 3) {
      return 'Tên đăng nhập tối thiểu 3 ký tự!';
    }

    if (password.length < 6) {
      return 'Mật khẩu phải từ 6 ký tự trở lên!';
    }

    // Check existing email/username
    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return 'Email này đã được đăng ký trong hệ thống!';
    }
    if (_users.any((u) => u.username.toLowerCase() == cleanUsername)) {
      return 'Tên đăng nhập này đã tồn tại!';
    }

    _pendingUser = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim(),
      email: cleanEmail,
      password: password,
      fullName: fullName.trim(),
      phone: phone.trim(),
      role: role,
    );

    _pendingEmail = cleanEmail;
    _pendingOtp = _generateOtp();
    notifyListeners();

    // Send real OTP email
    _lastEmailResult = await EmailService().sendOtpEmail(
      recipientEmail: cleanEmail,
      otpCode: _pendingOtp!,
      recipientName: fullName.trim(),
      isForRegister: true,
    );
    notifyListeners();

    return null; // success -> proceed to OTP
  }

  /// Verify Registration OTP & add user
  bool verifyRegisterOtp(String enteredOtp) {
    if (_pendingUser != null && _pendingOtp == enteredOtp.trim()) {
      _users.add(_pendingUser!);
      _currentUser = _pendingUser; // Auto login after verify
      _pendingUser = null;
      _pendingOtp = null;
      _pendingEmail = null;
      _lastEmailResult = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Resend OTP and re-dispatch Gmail
  Future<SendEmailResult> resendOtp() async {
    _pendingOtp = _generateOtp();
    notifyListeners();

    final targetEmail = _pendingEmail ?? '';
    final name = _pendingUser?.fullName ?? _pendingLoginUser?.fullName ?? 'Quý khách';
    final isReg = _pendingUser != null;

    final result = await EmailService().sendOtpEmail(
      recipientEmail: targetEmail,
      otpCode: _pendingOtp!,
      recipientName: name,
      isForRegister: isReg,
    );
    _lastEmailResult = result;
    notifyListeners();
    return result;
  }

  /// Quick Login for Demos / Testing
  void quickLogin(UserRole role) {
    final user = _users.firstWhere((u) => u.role == role);
    _currentUser = user;
    _pendingLoginUser = null;
    _pendingUser = null;
    _pendingOtp = null;
    _pendingEmail = null;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _pendingLoginUser = null;
    _pendingUser = null;
    _pendingOtp = null;
    _pendingEmail = null;
    notifyListeners();
  }

  // ==========================================
  // CRUD FOR USERS (Admin)
  // ==========================================

  void addUser(UserModel user) {
    _users.insert(0, user);
    notifyListeners();
  }

  void updateUser(UserModel updatedUser) {
    final idx = _users.indexWhere((u) => u.id == updatedUser.id);
    if (idx != -1) {
      _users[idx] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      notifyListeners();
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    _children.removeWhere((c) => c.ownerId == id);
    notifyListeners();
  }

  void toggleUserStatus(String id) {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isActive: !_users[idx].isActive);
      notifyListeners();
    }
  }

  // ==========================================
  // CRUD FOR CHILDREN (Admin, Staff, Customer)
  // ==========================================

  List<ChildProfile> getVisibleChildren() {
    if (_currentUser == null) return [];
    if (_currentUser!.role == UserRole.admin || _currentUser!.role == UserRole.staff) {
      return _children;
    }
    return _children.where((c) => c.ownerId == _currentUser!.id).toList();
  }

  void addChild(ChildProfile child) {
    _children.insert(0, child);
    notifyListeners();
  }

  void updateChild(ChildProfile updatedChild) {
    final idx = _children.indexWhere((c) => c.id == updatedChild.id);
    if (idx != -1) {
      _children[idx] = updatedChild;
      notifyListeners();
    }
  }

  void deleteChild(String id) {
    _children.removeWhere((c) => c.id == id);
    _rules.removeWhere((r) => r.childId == id);
    notifyListeners();
  }

  void toggleChildSafety(String id) {
    final idx = _children.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _children[idx] = _children[idx].copyWith(isSafe: !_children[idx].isSafe);
      notifyListeners();
    }
  }

  // ==========================================
  // CRUD FOR RULES (Admin, Staff, Customer)
  // ==========================================

  List<AppRule> getVisibleRules() {
    if (_currentUser == null) return [];
    if (_currentUser!.role == UserRole.admin || _currentUser!.role == UserRole.staff) {
      return _rules;
    }
    final myChildIds = _children.where((c) => c.ownerId == _currentUser!.id).map((c) => c.id).toSet();
    return _rules.where((r) => myChildIds.contains(r.childId)).toList();
  }

  void addRule(AppRule rule) {
    _rules.insert(0, rule);
    notifyListeners();
  }

  void updateRule(AppRule updatedRule) {
    final idx = _rules.indexWhere((r) => r.id == updatedRule.id);
    if (idx != -1) {
      _rules[idx] = updatedRule;
      notifyListeners();
    }
  }

  void deleteRule(String id) {
    _rules.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleRule(String id) {
    final idx = _rules.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _rules[idx] = _rules[idx].copyWith(isEnabled: !_rules[idx].isEnabled);
      notifyListeners();
    }
  }

  // ==========================================
  // CRUD FOR SUPPORT TICKETS (Staff, Customer)
  // ==========================================

  List<SupportTicket> getVisibleTickets() {
    if (_currentUser == null) return [];
    if (_currentUser!.role == UserRole.admin || _currentUser!.role == UserRole.staff) {
      return _tickets;
    }
    return _tickets.where((t) => t.customerId == _currentUser!.id).toList();
  }

  void addTicket(SupportTicket ticket) {
    _tickets.insert(0, ticket);
    notifyListeners();
  }

  void updateTicketStatus(String id, TicketStatus newStatus) {
    final idx = _tickets.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: newStatus,
        assignedStaffId: _currentUser?.id,
      );
      notifyListeners();
    }
  }

  void deleteTicket(String id) {
    _tickets.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
