class AppRule {
  final String id;
  final String childId;
  final String appName;
  final int limitMinutes;
  final String period; // 'Mỗi ngày', 'Ngày đi học', 'Cuối tuần'
  final bool isEnabled;

  AppRule({
    required this.id,
    required this.childId,
    required this.appName,
    required this.limitMinutes,
    this.period = 'Mỗi ngày',
    this.isEnabled = true,
  });

  String get formattedLimit => '$limitMinutes phút';

  AppRule copyWith({
    String? id,
    String? childId,
    String? appName,
    int? limitMinutes,
    String? period,
    bool? isEnabled,
  }) {
    return AppRule(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appName: appName ?? this.appName,
      limitMinutes: limitMinutes ?? this.limitMinutes,
      period: period ?? this.period,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
