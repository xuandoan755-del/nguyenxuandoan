import 'package:flutter/material.dart';

enum TicketStatus {
  pending,
  inProgress,
  resolved,
}

extension TicketStatusExtension on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.pending:
        return 'Chờ xử lý';
      case TicketStatus.inProgress:
        return 'Đang hỗ trợ';
      case TicketStatus.resolved:
        return 'Đã hoàn tất';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.pending:
        return const Color(0xFFE65100);
      case TicketStatus.inProgress:
        return const Color(0xFF1976D2);
      case TicketStatus.resolved:
        return const Color(0xFF2E7D32);
    }
  }

  Color get bgColor {
    switch (this) {
      case TicketStatus.pending:
        return const Color(0xFFFFF3E0);
      case TicketStatus.inProgress:
        return const Color(0xFFE3F2FD);
      case TicketStatus.resolved:
        return const Color(0xFFE8F5E9);
    }
  }
}

class SupportTicket {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final String content;
  final TicketStatus status;
  final String? assignedStaffId;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.content,
    this.status = TicketStatus.pending,
    this.assignedStaffId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SupportTicket copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    String? content,
    TicketStatus? status,
    String? assignedStaffId,
    DateTime? createdAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
