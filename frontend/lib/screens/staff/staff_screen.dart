import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../models/rule_model.dart';
import '../../models/ticket_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../customer/child_form_dialog.dart';
import '../customer/rule_form_dialog.dart';
import 'ticket_dialog.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final children = appState.children;
        final tickets = appState.tickets;
        final rules = appState.rules;

        final alertCount = children.where((c) => !c.isSafe).length;
        final pendingTicketCount = tickets.where((t) => t.status != TicketStatus.resolved).length;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.badge, color: Color(0xFF2E7D32), size: 20),
                    SizedBox(width: 8),
                    Text('DASHBOARD NHÂN VIÊN (STAFF)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                Text(
                  'Phụ trách: ${appState.currentUser?.fullName ?? 'Nhân viên'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: const Icon(Icons.devices_rounded), text: 'Thiết bị (${children.length})'),
                Tab(
                  icon: Badge(
                    label: Text('$pendingTicketCount'),
                    isLabelVisible: pendingTicketCount > 0,
                    child: const Icon(Icons.support_agent_rounded),
                  ),
                  text: 'Hỗ trợ (${tickets.length})',
                ),
                Tab(icon: const Icon(Icons.rule_folder_outlined), text: 'Quy tắc (${rules.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Devices monitored
              _buildDevicesMonitoringTab(context, appState, children, alertCount),

              // TAB 2: Support tickets CRUD
              _buildTicketsTab(context, appState, tickets),

              // TAB 3: App Rules
              _buildRulesTab(context, appState, rules, children),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDevicesMonitoringTab(
    BuildContext context,
    AppState appState,
    List<ChildProfile> children,
    int alertCount,
  ) {
    return Column(
      children: [
        // Staff status summary banner
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: alertCount > 0 ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: alertCount > 0 ? const Color(0xFFFFB74D) : const Color(0xFFA5D6A7)),
          ),
          child: Row(
            children: [
              Icon(
                alertCount > 0 ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                color: alertCount > 0 ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alertCount > 0
                          ? 'Cần xử lý: $alertCount thiết bị đang trong trạng thái Cảnh báo!'
                          : 'Tất cả thiết bị đều hoạt động an toàn!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: alertCount > 0 ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Nhân viên có thể kiểm tra, đổi trạng thái và điều chỉnh giới hạn cho phụ huynh.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(70, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ChildFormDialog(
                      onSave: (newChild) {
                        appState.addChild(newChild);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Nhân viên đã tạo hồ sơ mới: ${newChild.name}')),
                        );
                      },
                    ),
                  );
                },
                child: const Text('＋ Thêm trẻ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        Expanded(
          child: children.isEmpty
              ? const Center(child: Text('Không có thiết bị cần giám sát'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final c = children[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: c.statusBgColor,
                                  child: Text(c.initials, style: TextStyle(color: c.statusColor, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('${c.age} tuổi • ${c.device}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: c.statusBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: c.statusColor.withAlpha(100)),
                                  ),
                                  child: Text(
                                    c.statusLabel,
                                    style: TextStyle(color: c.statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (c.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FBF9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text('Ghi chú: ${c.notes}', style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Hôm nay: ${c.formattedUsage}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      icon: Icon(c.isSafe ? Icons.warning_amber_rounded : Icons.check_circle_outline, size: 16),
                                      label: Text(c.isSafe ? 'Đổi sang Cảnh báo' : 'Đổi sang An toàn', style: const TextStyle(fontSize: 11)),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(120, 32),
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      onPressed: () => appState.toggleChildSafety(c.id),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
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
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Xác nhận xóa hồ sơ'),
                                            content: Text('Xóa hồ sơ ${c.name}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  appState.deleteChild(c.id);
                                                },
                                                child: const Text('Xóa'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
  // TAB 2: SUPPORT TICKETS CRUD
  // ==========================================
  Widget _buildTicketsTab(BuildContext context, AppState appState, List<SupportTicket> tickets) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng: ${tickets.length} yêu cầu hỗ trợ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo yêu cầu'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => TicketDialog(
                      onSave: (ticket) {
                        appState.addTicket(ticket);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã tạo yêu cầu hỗ trợ mới')),
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
          child: tickets.isEmpty
              ? const Center(child: Text('Chưa có yêu cầu hỗ trợ nào'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: t.status.bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    t.status.label,
                                    style: TextStyle(color: t.status.color, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Khách hàng: ${t.customerName}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(t.content, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cập nhật trạng thái:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                Row(
                                  children: [
                                    if (t.status != TicketStatus.inProgress)
                                      TextButton(
                                        onPressed: () => appState.updateTicketStatus(t.id, TicketStatus.inProgress),
                                        child: const Text('Tiếp nhận', style: TextStyle(fontSize: 12)),
                                      ),
                                    if (t.status != TicketStatus.resolved)
                                      TextButton(
                                        onPressed: () => appState.updateTicketStatus(t.id, TicketStatus.resolved),
                                        child: const Text('Hoàn tất', style: TextStyle(fontSize: 12, color: AppColors.success)),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () => appState.deleteTicket(t.id),
                                    ),
                                  ],
                                ),
                              ],
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
  // TAB 3: APP RULES
  // ==========================================
  Widget _buildRulesTab(BuildContext context, AppState appState, List<AppRule> rules, List<ChildProfile> children) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quản lý ${rules.length} quy tắc an toàn', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm quy tắc'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => RuleFormDialog(
                      onSave: (rule) => appState.addRule(rule),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: rules.isEmpty
              ? const Center(child: Text('Chưa có quy tắc nào'))
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
                          backgroundColor: const Color(0xFFE8F5E9),
                          child: const Icon(Icons.timer, color: AppColors.primary),
                        ),
                        title: Text(r.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${child.name} • ${r.period} • Giới hạn ${r.formattedLimit}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(value: r.isEnabled, onChanged: (_) => appState.toggleRule(r.id)),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
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
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () => appState.deleteRule(r.id),
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
}
