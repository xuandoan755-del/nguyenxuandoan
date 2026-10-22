import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/app_state.dart';

class TicketDialog extends StatefulWidget {
  final SupportTicket? initialTicket;
  final Function(SupportTicket) onSave;

  const TicketDialog({super.key, this.initialTicket, required this.onSave});

  @override
  State<TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TicketStatus _status;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTicket;
    _titleController = TextEditingController(text: t?.title ?? '');
    _contentController = TextEditingController(text: t?.content ?? '');
    _status = t?.status ?? TicketStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final appState = AppState();
    final user = appState.currentUser;

    final ticket = SupportTicket(
      id: widget.initialTicket?.id ?? 't_${DateTime.now().millisecondsSinceEpoch}',
      customerId: widget.initialTicket?.customerId ?? (user?.id ?? 'u_customer'),
      customerName: widget.initialTicket?.customerName ?? (user?.fullName ?? 'Khách hàng'),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      status: _status,
      assignedStaffId: widget.initialTicket?.assignedStaffId,
      createdAt: widget.initialTicket?.createdAt,
    );

    widget.onSave(ticket);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTicket != null;

    return AlertDialog(
      title: Text(isEditing ? 'Cập nhật yêu cầu hỗ trợ' : 'Tạo yêu cầu hỗ trợ mới'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề yêu cầu',
                    hintText: 'Ví dụ: Cần điều chỉnh giới hạn máy bé...',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tiêu đề' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung chi tiết',
                    hintText: 'Mô tả vấn đề bạn cần hỗ trợ...',
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập nội dung' : null,
                ),
                if (isEditing) ...[
                  const SizedBox(height: 14),
                  const Text('TRẠNG THÁI XỬ LÝ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<TicketStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(),
                    items: TicketStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 42)),
          child: Text(isEditing ? 'Lưu' : 'Gửi yêu cầu'),
        ),
      ],
    );
  }
}
