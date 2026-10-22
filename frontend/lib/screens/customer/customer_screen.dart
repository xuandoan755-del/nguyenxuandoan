import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../models/rule_model.dart';
import '../../models/ticket_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'child_form_dialog.dart';
import 'rule_form_dialog.dart';
import '../staff/ticket_dialog.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final children = appState.getVisibleChildren();
        final rules = appState.getVisibleRules();
        final tickets = appState.getVisibleTickets();

        final filteredChildren = children.where((c) {
          final q = _searchCtrl.text.toLowerCase().trim();
          if (q.isEmpty) return true;
          return c.name.toLowerCase().contains(q) || c.device.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.family_restroom, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('GIA ĐÌNH BẢO AN (KHÁCH HÀNG)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                Text(
                  'Xin chào, ${appState.currentUser?.fullName ?? 'Phụ huynh'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: const Icon(Icons.escalator_warning_rounded), text: 'Con & Máy (${children.length})'),
                Tab(icon: const Icon(Icons.timer_outlined), text: 'Giới hạn (${rules.length})'),
                Tab(icon: const Icon(Icons.contact_support_outlined), text: 'Yêu cầu (${tickets.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Children list & management
              _buildChildrenTab(context, appState, filteredChildren, rules),

              // TAB 2: Rules list & management
              _buildRulesTab(context, appState, rules, children),

              // TAB 3: Support tickets
              _buildTicketsTab(context, appState, tickets),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChildrenTab(
    BuildContext context,
    AppState appState,
    List<ChildProfile> filteredChildren,
    List<AppRule> rules,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Welcome Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF24745D), Color(0xFF174D3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFFC3DED1), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'BẢO VỆ ĐANG HOẠT ĐỘNG',
                      style: TextStyle(
                        color: Color(0xFFC3DED1),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Chào mừng ${appState.currentUser?.fullName.split(' ').last ?? 'bạn'} 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cùng con xây dựng thói quen số lành mạnh, an toàn và cân bằng mỗi ngày.',
                  style: TextStyle(color: Color(0xFFD5E8DE), fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatPill('Hồ sơ trẻ: ${filteredChildren.length}'),
                    const SizedBox(width: 8),
                    _buildStatPill('Quy tắc bật: ${rules.where((r) => r.isEnabled).length}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search & Add child row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên bé, thiết bị...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchCtrl.clear()),
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm trẻ'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ChildFormDialog(
                      onSave: (newChild) {
                        appState.addChild(newChild);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm hồ sơ bé: ${newChild.name}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Children list cards
          if (filteredChildren.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.devices_other, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 10),
                    const Text('Chưa có hồ sơ trẻ nào.', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(140, 40)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => ChildFormDialog(
                            onSave: (child) => appState.addChild(child),
                          ),
                        );
                      },
                      child: const Text('Thêm hồ sơ đầu tiên'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredChildren.map((c) => _buildChildCard(context, appState, c)),
        ],
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, AppState appState, ChildProfile c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    c.initials,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${c.age} tuổi • ${c.device}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.statusColor.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: c.statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.statusLabel,
                        style: TextStyle(color: c.statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('THỜI GIAN HÔM NAY', style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(c.formattedUsage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Sửa', style: TextStyle(fontSize: 12)),
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
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: const Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 12)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xóa hồ sơ trẻ'),
                            content: Text('Xóa hồ sơ của bé ${c.name}? Giới hạn liên quan cũng sẽ bị xóa.'),
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
                    IconButton(
                      icon: Icon(c.isSafe ? Icons.warning_amber_rounded : Icons.check_circle, size: 20, color: c.statusColor),
                      tooltip: 'Đổi tình trạng an toàn/cảnh báo',
                      onPressed: () => appState.toggleChildSafety(c.id),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab(
    BuildContext context,
    AppState appState,
    List<AppRule> rules,
    List<ChildProfile> children,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${rules.length} quy tắc cài đặt', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm giới hạn'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(110, 40)),
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
              ? const Center(child: Text('Chưa có giới hạn ứng dụng nào'))
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
                        subtitle: Text('Bé: ${child.name} • ${r.period} • Giới hạn ${r.formattedLimit}'),
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

  Widget _buildTicketsTab(BuildContext context, AppState appState, List<SupportTicket> tickets) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${tickets.length} yêu cầu hỗ trợ', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Gửi hỗ trợ'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => TicketDialog(
                      onSave: (t) => appState.addTicket(t),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: tickets.isEmpty
              ? const Center(child: Text('Bạn chưa gửi yêu cầu hỗ trợ nào'))
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
                                Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: t.status.bgColor, borderRadius: BorderRadius.circular(10)),
                                  child: Text(t.status.label, style: TextStyle(color: t.status.color, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(t.content, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  label: const Text('Hủy yêu cầu', style: TextStyle(color: Colors.red, fontSize: 12)),
                                  onPressed: () => appState.deleteTicket(t.id),
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

  Widget _buildStatPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
