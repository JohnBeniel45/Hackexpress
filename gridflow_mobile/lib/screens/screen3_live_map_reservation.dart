import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../components/liquid_glass_card.dart';
import '../animations/spring_physics.dart';
import '../models/station.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

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
          decoration: BoxDecoration(
            color: const Color(0xE60A0E17),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
            boxShadow: const [
              BoxShadow(color: Colors.black, blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text(
                "APPLE WALLET CHARGING PASS",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppleLiquidColors.forestSheen, letterSpacing: 0.8),
              ),
              const SizedBox(height: 12),
              Text(_selectedStation.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(_selectedStation.address, style: const TextStyle(fontSize: 12, color: AppleLiquidColors.silver400)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("RESERVED BAY", style: TextStyle(fontSize: 9, color: AppleLiquidColors.silver400)),
                        Text(isUrgent ? "Bay #1 (120 kW)" : "Bay #2 (60 kW)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppleLiquidColors.forestSheen)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("SLOT TIME", style: TextStyle(fontSize: 9, color: AppleLiquidColors.silver400)),
                        Text(_slots[_selectedSlotIdx], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Simulated QR / NFC Sheen Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2, size: 70, color: Colors.black),
                    const Text(
                      "GF-PASS-8841-NFC",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, fontFamily: 'monospace'),
                    ),
                    const Text(
                      "TAP AT NFC CHARGER TERMINAL",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54),
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
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text("DONE & LOCK TO WALLET", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF042517))),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Live Map & Reservation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppleLiquidColors.forestEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppleLiquidColors.forestEmerald, width: 0.5),
                ),
                child: const Text(
                  "4 HUBS ONLINE",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppleLiquidColors.forestPrimary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // RADAR MAP CANVAS
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppleLiquidColors.forestEmerald.withOpacity(0.15)))),
                Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppleLiquidColors.forestEmerald.withOpacity(0.2)))),
                // User Location
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppleLiquidColors.forestPrimary, width: 3),
                    boxShadow: const [BoxShadow(color: AppleLiquidColors.forestPrimary, blurRadius: 16)],
                  ),
                ),
                // Station Blips
                _stationBlip(top: 40, right: 50, name: "Indiranagar (3)", color: AppleLiquidColors.forestPrimary),
                _stationBlip(bottom: 40, right: 60, name: "Koramangala (4)", color: AppleLiquidColors.forestPrimary),
                _stationBlip(top: 70, left: 40, name: "MG Road (0)", color: AppleLiquidColors.crimsonAlert),
                _stationBlip(bottom: 60, left: 50, name: "Whitefield (5)", color: AppleLiquidColors.forestPrimary),
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
                        Text(_selectedStation.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(_selectedStation.address, style: const TextStyle(fontSize: 11, color: AppleLiquidColors.silver400)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppleLiquidColors.forestEmerald.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${_selectedStation.chargersAvailable} FREE",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppleLiquidColors.forestPrimary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text("SELECT 15-MIN ARRIVAL SLOT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppleLiquidColors.silver400, letterSpacing: 0.5)),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(_slots.length, (idx) {
                    final isSel = _selectedSlotIdx == idx;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSlotIdx = idx),
                        child: Container(
                          margin: EdgeInsets.only(right: idx == _slots.length - 1 ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSel
                                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                                : null,
                            color: isSel ? null : const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? AppleLiquidColors.forestPrimary : Colors.white12, width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _slots[idx],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? const Color(0xFF042517) : Colors.white,
                                ),
                              ),
                              Text(
                                idx == 0 ? "Ready" : "+${(idx + 1) * 15}m",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSel ? const Color(0xFF042517).withOpacity(0.8) : AppleLiquidColors.silver400,
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x6610B981), blurRadius: 20, offset: Offset(0, 6)),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "CONFIRM & GENERATE DIGITAL PASS",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF042517)),
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

  Widget _stationBlip({double? top, double? bottom, double? left, double? right, required String name, required Color color}) {
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
              boxShadow: [BoxShadow(color: color, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
            child: Text(name, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
