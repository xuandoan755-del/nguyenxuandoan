import 'package:flutter/material.dart';
import '../../models/rule_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class RuleFormDialog extends StatefulWidget {
  final AppRule? initialRule;
  final Function(AppRule) onSave;

  const RuleFormDialog({super.key, this.initialRule, required this.onSave});

  @override
  State<RuleFormDialog> createState() => _RuleFormDialogState();
}

class _RuleFormDialogState extends State<RuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appNameController;
  late TextEditingController _limitController;
  late String _selectedChildId;
  late String _selectedPeriod;
  late bool _isEnabled;

  final List<String> _periods = ['Mỗi ngày', 'Ngày đi học', 'Cuối tuần'];
  final List<String> _commonApps = ['YouTube Kids', 'TikTok', 'Roblox Games', 'Facebook', 'Zalo', 'Trình duyệt Web'];

  @override
  void initState() {
    super.initState();
    final r = widget.initialRule;
    final appState = AppState();
    final visibleChildren = appState.getVisibleChildren();

    _appNameController = TextEditingController(text: r?.appName ?? 'YouTube');
    _limitController = TextEditingController(text: r?.limitMinutes != null ? r!.limitMinutes.toString() : '45');
    _selectedChildId = r?.childId ?? (visibleChildren.isNotEmpty ? visibleChildren.first.id : '');
    _selectedPeriod = r?.period ?? 'Mỗi ngày';
    _isEnabled = r?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tạo hồ sơ trẻ trước khi thêm giới hạn!')),
      );
      return;
    }

    final rule = AppRule(
      id: widget.initialRule?.id ?? 'r_${DateTime.now().millisecondsSinceEpoch}',
      childId: _selectedChildId,
      appName: _appNameController.text.trim(),
      limitMinutes: int.tryParse(_limitController.text.trim()) ?? 45,
      period: _selectedPeriod,
      isEnabled: _isEnabled,
    );

    widget.onSave(rule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRule != null;
    final appState = AppState();
    final visibleChildren = appState.getVisibleChildren();

    return AlertDialog(
      title: Text(isEditing ? 'Sửa giới hạn ứng dụng' : 'Thêm giới hạn ứng dụng mới'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visibleChildren.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chưa có hồ sơ trẻ nào! Hãy tạo hồ sơ trẻ trước.',
                      style: TextStyle(color: AppColors.danger, fontSize: 13),
                    ),
                  )
                else ...[
                  const Text('ÁP DỤNG CHO TRẺ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: visibleChildren.any((c) => c.id == _selectedChildId) ? _selectedChildId : visibleChildren.first.id,
                    decoration: const InputDecoration(),
                    items: visibleChildren.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.name} (${c.device})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedChildId = val);
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _appNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên ứng dụng / Thể loại',
                    hintText: 'Ví dụ: YouTube, TikTok, Roblox...',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên ứng dụng' : null,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _commonApps.map((app) {
                    return ActionChip(
                      label: Text(app, style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() => _appNameController.text = app);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian giới hạn (Phút / ngày)',
                    hintText: 'Ví dụ: 45',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nhập số phút';
                    final num = int.tryParse(v);
                    if (num == null || num <= 0 || num > 1440) return 'Từ 1 đến 1440 phút';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const Text('CHU KỲ ÁP DỤNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPeriod,
                  decoration: const InputDecoration(),
                  items: _periods.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Kích hoạt giới hạn này'),
                  value: _isEnabled,
                  onChanged: (val) => setState(() => _isEnabled = val),
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
