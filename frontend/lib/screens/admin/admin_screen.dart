import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/child_model.dart';
import '../../models/rule_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../customer/child_form_dialog.dart';
import '../customer/rule_form_dialog.dart';
import 'user_form_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchUserCtrl = TextEditingController();
  UserRole? _filterRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final users = appState.users;
        final children = appState.children;
        final rules = appState.rules;

        // Filtered users
        final filteredUsers = users.where((u) {
          final query = _searchUserCtrl.text.toLowerCase().trim();
          final matchesQuery = query.isEmpty ||
              u.fullName.toLowerCase().contains(query) ||
              u.username.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query);
          final matchesRole = _filterRole == null || u.role == _filterRole;
          return matchesQuery && matchesRole;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Color(0xFFD9534F), size: 20),
                    SizedBox(width: 8),
                    Text('TRUNG TÂM QUẢN TRỊ (ADMIN)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                Text(
                  'Xin chào, ${appState.currentUser?.fullName ?? 'Admin'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: const Icon(Icons.people_alt_outlined), text: 'Người dùng (${users.length})'),
                Tab(icon: const Icon(Icons.devices_other_outlined), text: 'Thiết bị (${children.length})'),
                Tab(icon: const Icon(Icons.security_outlined), text: 'Quy tắc (${rules.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: User Management (Full CRUD)
              _buildUsersTab(context, appState, filteredUsers),

              // TAB 2: Device & Child Management (Full CRUD)
              _buildDevicesTab(context, appState, children),

              // TAB 3: App Rules Management (Full CRUD)
              _buildRulesTab(context, appState, rules, children),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: USER MANAGEMENT CRUD
  // ==========================================
  Widget _buildUsersTab(BuildContext context, AppState appState, List<UserModel> filteredUsers) {
    return Column(
      children: [
        // Top KPI Banner
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tổng user', appState.users.length.toString(), Colors.blue),
              _buildStatItem('Admin', appState.users.where((u) => u.role == UserRole.admin).length.toString(), const Color(0xFFD9534F)),
              _buildStatItem('Nhân viên', appState.users.where((u) => u.role == UserRole.staff).length.toString(), const Color(0xFF2E7D32)),
              _buildStatItem('Khách hàng', appState.users.where((u) => u.role == UserRole.customer).length.toString(), const Color(0xFF1976D2)),
            ],
          ),
        ),

        // Search & Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchUserCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm người dùng theo tên, email...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchUserCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchUserCtrl.clear()),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<UserRole?>(
                initialValue: _filterRole,
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: _filterRole != null ? AppColors.primary : AppColors.textMuted,
                ),
                onSelected: (role) => setState(() => _filterRole = role),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: null, child: Text('Tất cả vai trò')),
                  const PopupMenuItem(value: UserRole.admin, child: Text('Chỉ Admin')),
                  const PopupMenuItem(value: UserRole.staff, child: Text('Chỉ Nhân viên')),
                  const PopupMenuItem(value: UserRole.customer, child: Text('Chỉ Khách hàng')),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Thêm'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => UserFormDialog(
                      onSave: (newUser) {
                        appState.addUser(newUser);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm người dùng: ${newUser.fullName}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // User List View
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(child: Text('Không tìm thấy người dùng phù hợp'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelf = user.id == appState.currentUser?.id;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role.color.withAlpha(30),
                          child: Icon(user.role.icon, color: user.role.color, size: 20),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: user.role.color.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.role.shortLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user.role.color),
                              ),
                            ),
                            if (!user.isActive) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Khóa', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${user.username} • ${user.email}\nSĐT: ${user.phone}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              showDialog(
                                context: context,
                                builder: (_) => UserFormDialog(
                                  initialUser: user,
                                  onSave: (updated) {
                                    appState.updateUser(updated);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Cập nhật thành công: ${updated.fullName}')),
                                    );
                                  },
                                ),
                              );
                            } else if (val == 'toggle') {
                              appState.toggleUserStatus(user.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(user.isActive ? 'Đã khóa tài khoản ${user.username}' : 'Đã mở khóa tài khoản ${user.username}'),
                                ),
                              );
                            } else if (val == 'delete') {
                              if (isSelf) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bạn không thể tự xóa tài khoản đang đăng nhập!')),
                                );
                                return;
                              }
                              _confirmDelete(
                                context,
                                'Xóa người dùng',
                                'Bạn có chắc chắn muốn xóa tài khoản ${user.fullName} (${user.username})?',
                                () => appState.deleteUser(user.id),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sửa thông tin'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(user.isActive ? Icons.lock_outline : Icons.lock_open, size: 18),
                                  SizedBox(width: 8),
                                  Text(user.isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                                ],
                              ),
                            ),
                            if (!isSelf)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Xóa tài khoản', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: DEVICE / CHILD CRUD
  // ==========================================
  Widget _buildDevicesTab(BuildContext context, AppState appState, List<ChildProfile> children) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng: ${children.length} hồ sơ trẻ em & thiết bị',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm trẻ'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(90, 40)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ChildFormDialog(
                      onSave: (newChild) {
                        appState.addChild(newChild);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm hồ sơ: ${newChild.name}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: children.isEmpty
              ? const Center(child: Text('Chưa có hồ sơ thiết bị nào'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final c = children[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(c.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${c.age} tuổi • ${c.device}\nThời gian dùng: ${c.formattedUsage}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                c.isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                                color: c.statusColor,
                              ),
                              tooltip: 'Chuyển trạng thái an toàn/cảnh báo',
                              onPressed: () => appState.toggleChildSafety(c.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ChildFormDialog(
                                    initialChild: c,
                                    onSave: (updated) => appState.updateChild(updated),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(
                                  context,
                                  'Xóa hồ sơ',
                                  'Xóa hồ sơ ${c.name}? Tất cả quy tắc giới hạn của trẻ cũng sẽ bị xóa.',
                                  () => appState.deleteChild(c.id),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: APP RULES CRUD
  // ==========================================
  Widget _buildRulesTab(BuildContext context, AppState appState, List<AppRule> rules, List<ChildProfile> children) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng: ${rules.length} quy tắc an toàn',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm quy tắc'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(90, 40)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => RuleFormDialog(
                      onSave: (newRule) {
                        appState.addRule(newRule);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã tạo giới hạn cho: ${newRule.appName}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: rules.isEmpty
              ? const Center(child: Text('Chưa có quy tắc giới hạn nào'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final r = rules[index];
                    final child = children.firstWhere(
                      (c) => c.id == r.childId,
                      orElse: () => ChildProfile(id: '', ownerId: '', name: 'Đã xóa', age: 0, device: ''),
                    );

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF0F4E9),
                          child: const Icon(Icons.timer_outlined, color: Color(0xFF78904E)),
                        ),
                        title: Text(r.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Trẻ: ${child.name} • Chu kỳ: ${r.period}\nGiới hạn: ${r.formattedLimit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: r.isEnabled,
                              onChanged: (_) => appState.toggleRule(r.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RuleFormDialog(
                                    initialRule: r,
                                    onSave: (updated) => appState.updateRule(updated),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(
                                  context,
                                  'Xóa quy tắc',
                                  'Xóa giới hạn ứng dụng ${r.appName}?',
                                  () => appState.deleteRule(r.id),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String title, String message, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirmed();
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }
}
