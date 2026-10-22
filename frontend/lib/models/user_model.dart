import 'package:flutter/material.dart';

enum UserRole {
  admin,
  staff,
  customer,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
      case UserRole.staff:
        return 'Nhân viên (Staff)';
      case UserRole.customer:
        return 'Khách hàng / Phụ huynh';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Nhân viên';
      case UserRole.customer:
        return 'Khách hàng';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Toàn quyền quản trị hệ thống, quản lý người dùng & dữ liệu.';
      case UserRole.staff:
        return 'Xử lý yêu cầu, giám sát thiết bị và hỗ trợ người dùng.';
      case UserRole.customer:
        return 'Quản lý hồ sơ trẻ, thiết lập quy tắc bảo vệ và gửi hỗ trợ.';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return const Color(0xFFD9534F); // Đỏ gạch sang trọng
      case UserRole.staff:
        return const Color(0xFF2E7D32); // Xanh lá đậm
      case UserRole.customer:
        return const Color(0xFF1976D2); // Xanh dương
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.staff:
        return Icons.badge_rounded;
      case UserRole.customer:
        return Icons.family_restroom_rounded;
    }
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
