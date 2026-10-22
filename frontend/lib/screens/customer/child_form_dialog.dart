import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/app_state.dart';

class ChildFormDialog extends StatefulWidget {
  final ChildProfile? initialChild;
  final Function(ChildProfile) onSave;

  const ChildFormDialog({super.key, this.initialChild, required this.onSave});

  @override
  State<ChildFormDialog> createState() => _ChildFormDialogState();
}

class _ChildFormDialogState extends State<ChildFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _deviceController;
  late TextEditingController _notesController;
  late bool _isSafe;

  @override
  void initState() {
    super.initState();
    final c = widget.initialChild;
    _nameController = TextEditingController(text: c?.name ?? '');
    _ageController = TextEditingController(text: c?.age != null ? c!.age.toString() : '');
    _deviceController = TextEditingController(text: c?.device ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _isSafe = c?.isSafe ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _deviceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppState();
    final currentUserId = appState.currentUser?.id ?? 'u_customer';

    final child = ChildProfile(
      id: widget.initialChild?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: widget.initialChild?.ownerId ?? currentUserId,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 10,
      device: _deviceController.text.trim(),
      dailyUsageMinutes: widget.initialChild?.dailyUsageMinutes ?? 0,
      isSafe: _isSafe,
      notes: _notesController.text.trim(),
    );

    widget.onSave(child);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialChild != null;

    return AlertDialog(
      title: Text(isEditing ? 'Sửa hồ sơ trẻ & thiết bị' : 'Thêm hồ sơ trẻ mới'),
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên của trẻ',
                    hintText: 'Ví dụ: Nguyễn Minh Khang',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên của trẻ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Tuổi của trẻ',
                    hintText: 'Ví dụ: 10',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nhập tuổi của trẻ';
                    final age = int.tryParse(v);
                    if (age == null || age < 1 || age > 18) return 'Tuổi từ 1 đến 18';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deviceController,
                  decoration: const InputDecoration(
                    labelText: 'Thiết bị sử dụng',
                    hintText: 'Ví dụ: iPhone 12, Xiaomi Redmi...',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên thiết bị' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú an toàn',
                    hintText: 'Ví dụ: Giới hạn ban đêm, học bài online...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Trạng thái an toàn'),
                  subtitle: Text(_isSafe ? 'An toàn' : 'Cần chú ý / Cảnh báo'),
                  value: _isSafe,
                  onChanged: (val) => setState(() => _isSafe = val),
                  contentPadding: EdgeInsets.zero,
                ),
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
          child: Text(isEditing ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}
