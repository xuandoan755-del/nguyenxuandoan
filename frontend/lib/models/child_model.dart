import 'package:flutter/material.dart';

class ChildProfile {
  final String id;
  final String ownerId; // Id của phụ huynh / khách hàng sở hữu
  final String name;
  final int age;
  final String device;
  final int dailyUsageMinutes;
  final bool isSafe;
  final String notes;
  final DateTime updatedAt;

  ChildProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.age,
    required this.device,
    this.dailyUsageMinutes = 0,
    this.isSafe = true,
    this.notes = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'B';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[parts.length - 2][0] + parts.last[0]).toUpperCase();
  }

  String get formattedUsage {
    final h = dailyUsageMinutes ~/ 60;
    final m = dailyUsageMinutes % 60;
    if (h == 0) return '$m phút';
    return '$h giờ $m phút';
  }

  String get statusLabel => isSafe ? 'An toàn' : 'Cần chú ý';

  Color get statusColor => isSafe ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
  Color get statusBgColor => isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

  ChildProfile copyWith({
    String? id,
    String? ownerId,
    String? name,
    int? age,
    String? device,
    int? dailyUsageMinutes,
    bool? isSafe,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      age: age ?? this.age,
      device: device ?? this.device,
      dailyUsageMinutes: dailyUsageMinutes ?? this.dailyUsageMinutes,
      isSafe: isSafe ?? this.isSafe,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
