import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../components/liquid_glass_card.dart';
import '../animations/spring_physics.dart';
import '../models/station.dart';
import '../models/user_profile.dart';

class Screen3LiveMapReservation extends StatefulWidget {
  final UserProfile profile;
  final Station? preselectedStation;

  const Screen3LiveMapReservation({
    Key? key,
    required this.profile,
    this.preselectedStation,
  }) : super(key: key);

  @override
  State<Screen3LiveMapReservation> createState() => _Screen3LiveMapReservationState();
}

class _Screen3LiveMapReservationState extends State<Screen3LiveMapReservation> {
  late Station _selectedStation;
  int _selectedSlotIdx = 0;
  final List<String> _slots = ["18:45", "19:00", "19:15", "19:30"];

  final List<Station> _stations = [
    Station(
      id: 2,
      name: "Koramangala FastCharge",
      address: "Hosur Rd, 7th Block",
      lat: 12.9352,
      lon: 77.6146,
      chargersTotal: 6,
      chargersAvailable: 4,
      status: "active",
      gridLoad: 0.45,
      powerKw: 60.0,
      connectorTypes: ["CCS2", "Type 2 AC"],
      predictedWaitMin: 4.2,
      distanceKm: 3.8,
    ),
    Station(
      id: 1,
      name: "Indiranagar 100ft Hub",
      address: "100 Feet Rd, HAL 2nd Stage",
      lat: 12.9716,
      lon: 77.6412,
      chargersTotal: 8,
      chargersAvailable: 3,
      status: "active",
      gridLoad: 0.65,
      powerKw: 120.0,
      connectorTypes: ["CCS2", "Type 2 AC"],
      predictedWaitMin: 8.5,
      distanceKm: 2.4,
    ),
    Station(
      id: 3,
      name: "MG Road Metro Super Hub",
      address: "Trinity Circle, MG Road",
      lat: 12.9756,
      lon: 77.6066,
      chargersTotal: 4,
      chargersAvailable: 0,
      status: "busy",
      gridLoad: 0.88,
      powerKw: 150.0,
      connectorTypes: ["CCS2", "CHAdeMO"],
      predictedWaitMin: 24.5,
      distanceKm: 1.2,
    ),
    Station(
      id: 4,
      name: "Whitefield ITPL PowerPort",
      address: "ITPL Main Rd, Whitefield",
      lat: 12.9863,
      lon: 77.7305,
      chargersTotal: 10,
      chargersAvailable: 5,
      status: "active",
      gridLoad: 0.52,
      powerKw: 120.0,
      connectorTypes: ["CCS2", "Type 2 AC"],
      predictedWaitMin: 7.0,
      distanceKm: 8.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.preselectedStation ?? _stations[0];
  }

  void _showApplePassModal() {
    final isUrgent = widget.profile.isEmergency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(color: Color(0x330F172A), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text(
                "APPLE WALLET CHARGING PASS",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppleLiquidColors.skyVibrant, letterSpacing: 0.8),
              ),
              const SizedBox(height: 12),
              Text(_selectedStation.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
              Text(_selectedStation.address, style: const TextStyle(fontSize: 12, color: AppleLiquidColors.textCaption)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("RESERVED BAY", style: TextStyle(fontSize: 9, color: AppleLiquidColors.textCaption)),
                        const SizedBox(height: 2),
                        Text(isUrgent ? "Bay #1 (120 kW Fast)" : "Bay #1 (60 kW DC)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppleLiquidColors.natureEmerald)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("SLOT TIME", style: TextStyle(fontSize: 9, color: AppleLiquidColors.textCaption)),
                        const SizedBox(height: 2),
                        Text(_slots[_selectedSlotIdx], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppleLiquidColors.textHeadline)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TactileSpringButton(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppleLiquidColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x4D00A3FF), blurRadius: 18, offset: Offset(0, 6)),
                    ],
                  ),
                  child: const Center(
                    child: Text("DONE & LOCK TO WALLET", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cur = _selectedStation;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Charging Network Map",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppleLiquidColors.textHeadline),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Live station availability & queue lengths",
                    style: TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppleLiquidColors.skyAura,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4D0284C7), width: 0.5),
                ),
                child: const Text(
                  "4 HUBS LIVE",
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppleLiquidColors.skyVibrant),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // REALISTIC VECTOR MINI-MAP COMPONENT
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF4FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 0.8),
              boxShadow: const [
                BoxShadow(color: Color(0x140F172A), blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Vector Road Canvas Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MiniMapRoadPainter(),
                    ),
                  ),

                  // User Location GPS Puck
                  Positioned(
                    top: 105,
                    left: 135,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppleLiquidColors.skyElectric,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0x8000A3FF), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xD90F172A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("You", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  // Real Interactive Station Map Pins
                  // 1. Koramangala FastCharge
                  _stationPill(
                    station: _stations[0],
                    bottom: 20,
                    left: 25,
                    meta: "1 in queue • ₹14/kWh • 3.8 km",
                    isEmerald: true,
                  ),

                  // 2. Indiranagar 100ft Hub
                  _stationPill(
                    station: _stations[1],
                    top: 18,
                    right: 14,
                    meta: "2 in queue • ₹15.5/kWh • 2.4 km",
                    isEmerald: true,
                  ),

                  // 3. MG Road Metro Super Hub
                  _stationPill(
                    station: _stations[2],
                    top: 55,
                    left: 12,
                    meta: "4 in queue (Busy) • ₹17/kWh • 1.2 km",
                    isEmerald: false,
                  ),

                  // 4. Whitefield ITPL
                  _stationPill(
                    station: _stations[3],
                    bottom: 40,
                    right: 14,
                    meta: "2 in queue • ₹14.5/kWh • 8.5 km",
                    isEmerald: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SELECTED STATION DETAIL & RESERVATION CARD
          LiquidGlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cur.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                          Text(cur.address, style: const TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cur.chargersAvailable > 0 ? AppleLiquidColors.skyAura : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cur.chargersAvailable > 0 ? "${cur.chargersAvailable} FREE" : "FULL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: cur.chargersAvailable > 0 ? AppleLiquidColors.skyVibrant : AppleLiquidColors.crimsonAlert,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 4 Clean Badges
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricBadge("QUEUE", "${cur.id == 3 ? 4 : (cur.id == 2 ? 1 : 2)} cars", cur.id == 3 ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald),
                      _metricBadge("PRICE", "₹${cur.id == 1 ? '15.5' : (cur.id == 2 ? '14.0' : (cur.id == 3 ? '17.0' : '14.5'))}", AppleLiquidColors.textHeadline),
                      _metricBadge("DIST.", "${cur.distanceKm ?? 3.8} km", AppleLiquidColors.textHeadline),
                      _metricBadge("WAIT", "~${cur.predictedWaitMin.toStringAsFixed(1)}m", AppleLiquidColors.skyVibrant),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Text("SELECT 15-MIN ARRIVAL SLOT", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppleLiquidColors.textCaption, letterSpacing: 0.5)),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(_slots.length, (idx) {
                    final isSel = _selectedSlotIdx == idx;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSlotIdx = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: idx == _slots.length - 1 ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            gradient: isSel ? AppleLiquidColors.primaryGradient : null,
                            color: isSel ? null : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSel ? Colors.transparent : const Color(0xFFE2E8F0), width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: isSel ? const Color(0x4000A3FF) : const Color(0x08000000),
                                blurRadius: isSel ? 12 : 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                _slots[idx],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : AppleLiquidColors.textHeadline,
                                ),
                              ),
                              Text(
                                idx == 0 ? "Ready" : "+${(idx + 1) * 15}m",
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: isSel ? Colors.white70 : AppleLiquidColors.textCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 14),

                TactileSpringButton(
                  onTap: _showApplePassModal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppleLiquidColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4D00A3FF), blurRadius: 18, offset: Offset(0, 6)),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "CONFIRM & GENERATE DIGITAL PASS",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8.5, color: AppleLiquidColors.textCaption, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: valColor, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _stationPill({
    required Station station,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String meta,
    required bool isEmerald,
  }) {
    final isSelected = _selectedStation.id == station.id;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () => setState(() => _selectedStation = station),
        child: AnimatedScale(
          scale: isSelected ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppleLiquidColors.skyElectric : Colors.white,
                width: isSelected ? 1.2 : 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x4000A3FF) : const Color(0x1F0F172A),
                  blurRadius: isSelected ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isEmerald ? AppleLiquidColors.natureLeaf : AppleLiquidColors.crimsonAlert,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isEmerald ? const Color(0x8010B981) : const Color(0x80EF4444),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(station.name, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                    Text(meta, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppleLiquidColors.textCaption)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniMapRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Water Body
    final waterPaint = Paint()..color = const Color(0x99BAE6FD);
    final waterPath = Path()
      ..moveTo(0, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.3, size.width * 0.22, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.75, 0, size.height * 0.85)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // 2. Green Parkland
    final parkPaint = Paint()..color = const Color(0xBFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.5, 15, size.width * 0.26, 45), const Radius.circular(12)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.65, size.width * 0.2, 50), const Radius.circular(10)),
      parkPaint,
    );

    // 3. Secondary Streets
    final streetPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), streetPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.68, 0), Offset(size.width * 0.68, size.height), streetPaint);

    // 4. Primary Avenues (Casing + Surface)
    // 100 Ft Rd Diagonal
    final casingPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.18, 0), Offset(size.width * 0.9, size.height), casingPaint);
    canvas.drawLine(Offset(size.width * 0.18, 0), Offset(size.width * 0.9, size.height), roadPaint);

    // Hosur Road Curve (Warm yellow highway)
    final hwCasing = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hwPaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hwPath = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.36, size.width, size.height * 0.65);
    canvas.drawPath(hwPath, hwCasing);
    canvas.drawPath(hwPath, hwPaint);

    // MG Road East-West
    canvas.drawLine(Offset(0, size.height * 0.58), Offset(size.width, size.height * 0.58), casingPaint);
    canvas.drawLine(Offset(0, size.height * 0.58), Offset(size.width, size.height * 0.58), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
