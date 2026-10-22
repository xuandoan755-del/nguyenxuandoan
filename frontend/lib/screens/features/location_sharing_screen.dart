import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class LocationSharingScreen extends StatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  final _appState = AppState();
  Timer? _locationTimer;

  // Mock live coordinates for children (Hanoi, Vietnam)
  double _latitude = 21.0333;
  double _longitude = 105.8500;
  String _address = 'Trường Tiểu học Chu Văn An, Tây Hồ, Hà Nội';
  String _selectedChildId = '';
  bool _isInSafeZone = true;
  bool _isSosActive = false;
  int _batteryLevel = 86;

  final List<Map<String, dynamic>> _safeZones = [
    {'name': 'Trường học', 'lat': 21.0333, 'lng': 105.8500, 'radius': 200},
    {'name': 'Nhà riêng', 'lat': 21.0285, 'lng': 105.8542, 'radius': 150},
    {'name': 'Nhà sách', 'lat': 21.0310, 'lng': 105.8480, 'radius': 100},
  ];

  @override
  void initState() {
    super.initState();
    final children = _appState.getVisibleChildren();
    if (children.isNotEmpty) {
      _selectedChildId = children.first.id;
    }

    // Simulate subtle GPS jitter/updates
    _locationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          // slight coordinate drift simulation
          _latitude += (DateTime.now().second % 2 == 0 ? 0.00005 : -0.00003);
          _longitude += (DateTime.now().second % 3 == 0 ? 0.00004 : -0.00002);
        });
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _shareLocation() {
    final mapsUrl = 'https://maps.google.com/?q=$_latitude,$_longitude';
    Clipboard.setData(ClipboardData(text: mapsUrl));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share_location_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Chia sẻ vị trí thành công'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đường dẫn vị trí Google Maps đã được sao chép vào bộ nhớ tạm:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                mapsUrl,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 10),
            Text('Toạ độ: ${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}'),
            Text('Địa chỉ: $_address'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _triggerSos() {
    setState(() => _isSosActive = !_isSosActive);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSosActive
              ? '🚨 ĐÃ PHÁT TÍN HIỆU SOS! Toạ độ khẩn cấp đã gửi tới Phụ huynh và Nhân viên trực.'
              : 'Đã huỷ tín hiệu SOS.',
        ),
        backgroundColor: _isSosActive ? AppColors.danger : AppColors.primary,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = _appState.getVisibleChildren();
    final currentChild = children.firstWhere(
      (c) => c.id == _selectedChildId,
      orElse: () => ChildProfile(id: '', ownerId: '', name: 'Thiết bị của bé', age: 10, device: 'iPhone'),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.near_me_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Định vị & Chia sẻ vị trí', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Child Selector Row
            if (children.isNotEmpty) ...[
              const Text('CHỌN THIẾT BỊ THEO DÕI VỊ TRÍ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: children.map((c) {
                    final isSel = c.id == _selectedChildId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: isSel ? Colors.white : AppColors.primaryLight,
                          child: Text(c.initials, style: TextStyle(fontSize: 10, color: isSel ? AppColors.primary : AppColors.textDark, fontWeight: FontWeight.bold)),
                        ),
                        label: Text('${c.name} (${c.device})'),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedChildId = c.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // SOS Alert Banner if active
            if (_isSosActive)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ĐANG PHÁT CẢNH BÁO SOS VỊ TRÍ KHẨN CẤP!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Đang truyền tín hiệu vị trí GPS thời gian thực tới tất cả liên hệ tin cậy.', style: TextStyle(fontSize: 11, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Live Visual Map Widget (Custom Illustrated Map Canvas)
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                color: const Color(0xFFE5EFE7),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Illustrated Map Background (Roads, Green spaces, Zones)
                  CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: _MapGridPainter(),
                  ),

                  // Safe Zone Geofence Circle
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withAlpha(120), width: 1.5),
                      ),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 6),
                      child: const Text(
                        'Vùng an toàn (200m)',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ),
                  ),

                  // Center Pin: Child Location
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            currentChild.name,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Icon(Icons.location_pin, color: Color(0xFFD9534F), size: 36),
                      ],
                    ),
                  ),

                  // Top right map badges
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.battery_5_bar_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('$_batteryLevel%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Icon(Icons.satellite_alt_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 2),
                          const Text('GPS Live', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),

                  // Bottom left safe zone pill
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _isInSafeZone ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _isInSafeZone ? AppColors.success : AppColors.danger),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isInSafeZone ? Icons.check_circle : Icons.warning_rounded, size: 14, color: _isInSafeZone ? AppColors.success : AppColors.danger),
                          const SizedBox(width: 6),
                          Text(
                            _isInSafeZone ? 'Trong vùng an toàn: Trường học' : 'CẢNH BÁO: Rời vùng an toàn!',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _isInSafeZone ? AppColors.success : AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.place_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('ĐỊA CHỈ HIỆN TẠI CỦA THIẾT BỊ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCoordChip('Vĩ độ (Lat)', _latitude.toStringAsFixed(6)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCoordChip('Kinh độ (Long)', _longitude.toStringAsFixed(6)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Chia sẻ vị trí'),
                            onPressed: _shareLocation,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.emergency_rounded, size: 18, color: _isSosActive ? Colors.white : AppColors.danger),
                            label: Text(_isSosActive ? 'Tắt SOS' : 'Phát SOS'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isSosActive ? AppColors.danger : Colors.transparent,
                              foregroundColor: _isSosActive ? Colors.white : AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                            ),
                            onPressed: _triggerSos,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Geofence Zones List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DANH SÁCH VÙNG AN TOÀN (GEOFENCE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        TextButton(
                          onPressed: () {
                            setState(() => _isInSafeZone = !_isInSafeZone);
                          },
                          child: Text(_isInSafeZone ? 'Mô phỏng Rời vùng' : 'Mô phỏng Vào vùng', style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._safeZones.map((zone) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight,
                          child: const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                        ),
                        title: Text(zone['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Bán kính bảo vệ: ${zone['radius']}m • Tự động báo khi con đến/rời'),
                        trailing: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadBorder = Paint()
      ..color = const Color(0xFFB5C9BC)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final parkPaint = Paint()
      ..color = const Color(0xFFC7E3D0)
      ..style = PaintingStyle.fill;

    // Green parks
    canvas.drawRect(Rect.fromLTWH(10, 10, 80, 60), parkPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 100, 130, 90, 70), parkPaint);

    // Main road horizontal
    final pathH = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.45);
    canvas.drawPath(pathH, roadBorder);
    canvas.drawPath(pathH, roadPaint);

    // Main road vertical
    final pathV = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);
    canvas.drawPath(pathV, roadBorder);
    canvas.drawPath(pathV, roadPaint);

    // Secondary diagonal road
    final pathD = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.75, 0);
    final secondaryRoad = Paint()
      ..color = Colors.white.withAlpha(150)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(pathD, secondaryRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
