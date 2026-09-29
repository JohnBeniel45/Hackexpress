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

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.preselectedStation ??
        Station(
          id: 1,
          name: "Indiranagar 100ft EV Hub",
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
        );
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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppleLiquidColors.natureEmerald, letterSpacing: 0.8),
              ),
              const SizedBox(height: 12),
              Text(_selectedStation.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
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
                        Text(isUrgent ? "Bay #1 (120 kW Fast)" : "Bay #2 (60 kW DC)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppleLiquidColors.natureEmerald)),
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
              const SizedBox(height: 16),
              // Barcode / NFC Card Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.qr_code_2, size: 70, color: AppleLiquidColors.textHeadline),
                    SizedBox(height: 4),
                    Text(
                      "GF-PASS-8841-NFC",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline, fontFamily: 'monospace'),
                    ),
                    Text(
                      "HOLD NEAR NFC CHARGER TERMINAL",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppleLiquidColors.textCaption),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TactileSpringButton(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x5910B981), blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Center(
                    child: Text("DONE & LOCK TO WALLET", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
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
                    "Live Map & Slots",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppleLiquidColors.textHeadline),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Real-time corridor bay reservations",
                    style: TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppleLiquidColors.mintContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppleLiquidColors.natureMint, width: 0.5),
                ),
                child: const Text(
                  "4 HUBS READY",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppleLiquidColors.natureEmerald),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // RADAR MAP CANVAS (Light Nature)
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0FDF4), Color(0xFFE0F2FE)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x0F0F172A), blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppleLiquidColors.natureEmerald.withOpacity(0.2)))),
                Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppleLiquidColors.natureEmerald.withOpacity(0.25)))),
                // User Location
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppleLiquidColors.natureEmerald, width: 3.5),
                    boxShadow: const [BoxShadow(color: Color(0x66059669), blurRadius: 16)],
                  ),
                ),
                // Station Pins
                _stationPin(top: 35, right: 45, name: "Indiranagar (3)", color: AppleLiquidColors.natureEmerald),
                _stationPin(bottom: 35, right: 55, name: "Koramangala (4)", color: AppleLiquidColors.natureEmerald),
                _stationPin(top: 60, left: 35, name: "MG Road (0)", color: AppleLiquidColors.crimsonAlert),
                _stationPin(bottom: 50, left: 45, name: "Whitefield (5)", color: AppleLiquidColors.natureEmerald),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SELECTED STATION CARD
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedStation.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                        Text(_selectedStation.address, style: const TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppleLiquidColors.mintContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${_selectedStation.chargersAvailable} FREE",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppleLiquidColors.natureEmerald),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text("SELECT 15-MIN ARRIVAL SLOT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppleLiquidColors.textCaption, letterSpacing: 0.5)),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(_slots.length, (idx) {
                    final isSel = _selectedSlotIdx == idx;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSlotIdx = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          margin: EdgeInsets.only(right: idx == _slots.length - 1 ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            gradient: isSel
                                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                                : null,
                            color: isSel ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSel ? AppleLiquidColors.natureEmerald : const Color(0xFFE2E8F0), width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: isSel ? const Color(0x4010B981) : const Color(0x08000000),
                                blurRadius: isSel ? 14 : 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                _slots[idx],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : AppleLiquidColors.textHeadline,
                                ),
                              ),
                              Text(
                                idx == 0 ? "Ready" : "+${(idx + 1) * 15}m",
                                style: TextStyle(
                                  fontSize: 9,
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

                const SizedBox(height: 18),

                TactileSpringButton(
                  onTap: _showApplePassModal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x5910B981), blurRadius: 20, offset: Offset(0, 8)),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "CONFIRM & GENERATE DIGITAL PASS",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
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

  Widget _stationPin({double? top, double? bottom, double? left, double? right, required String name, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4)],
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
            ),
            child: Text(name, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
          ),
        ],
      ),
    );
  }
}
