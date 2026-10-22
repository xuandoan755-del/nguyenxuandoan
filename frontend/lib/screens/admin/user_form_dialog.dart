import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? initialUser;
  final Function(UserModel) onSave;

  const UserFormDialog({super.key, this.initialUser, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late UserRole _role;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;
    _fullNameController = TextEditingController(text: u?.fullName ?? '');
    _usernameController = TextEditingController(text: u?.username ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _passwordController = TextEditingController(text: u?.password ?? '');
    _role = u?.role ?? UserRole.customer;
    _isActive = u?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      id: widget.initialUser?.id ?? 'u_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
      isActive: _isActive,
      createdAt: widget.initialUser?.createdAt,
    );

    widget.onSave(user);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialUser != null;

    return AlertDialog(
      title: Text(isEditing ? 'Sửa thông tin người dùng' : 'Thêm người dùng mới'),
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
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                  validator: (v) => v == null || v.trim().length < 3 ? 'Tên từ 3 ký tự' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Email không hợp lệ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  validator: (v) => v == null || v.length < 6 ? 'Mật khẩu từ 6 ký tự' : null,
                ),
                const SizedBox(height: 16),
                const Text('VAI TRÒ (PHÂN QUYỀN)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(),
                  items: UserRole.values.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _role = val);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Trạng thái kích hoạt'),
                  subtitle: Text(_isActive ? 'Đang hoạt động' : 'Tạm khóa'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
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
          child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm mới'),
        ),
      ],
    );
  }
}
