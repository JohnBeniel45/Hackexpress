import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../components/liquid_glass_card.dart';
import '../components/liquid_morphing_slider.dart';
import '../animations/spring_physics.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class Screen2V2VHub extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onStateUpdated;

  const Screen2V2VHub({
    Key? key,
    required this.profile,
    required this.onStateUpdated,
  }) : super(key: key);

  @override
  State<Screen2V2VHub> createState() => _Screen2V2VHubState();
}

class _Screen2V2VHubState extends State<Screen2V2VHub> with SingleTickerProviderStateMixin {
  late AnimationController _beamController;
  double _transferKwh = 10.0;
  bool _isTransferring = false;

  // Realistic Demo Match State
  double _donorBattery = 92.0;
  final String _donorModel = "Hyundai Ioniq 5";
  final double _proximityKm = 0.4;

  @override
  void initState() {
    super.initState();
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _beamController.dispose();
    super.dispose();
  }

  void _executeTransfer() async {
    setState(() => _isTransferring = true);
    await Future.delayed(const Duration(milliseconds: 900));

    // Instant optimistic state update
    final addedPct = (_transferKwh / 40.5) * 100.0;
    final droppedPct = (_transferKwh / 72.6) * 100.0;

    setState(() {
      widget.profile.batteryPct = (widget.profile.batteryPct + addedPct).clamp(0.0, 100.0);
      _donorBattery = (_donorBattery - droppedPct).clamp(15.0, 100.0);
      widget.profile.ecoCredits += (_transferKwh * 15).toInt();
      _isTransferring = false;
    });

    widget.onStateUpdated();

    // Background server call
    ApiService.transferEnergy(
      donorId: "peer_ioniq_01",
      receiverId: widget.profile.userId,
      kwh: _transferKwh,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            "⚡ V2V Complete: +${_transferKwh.toInt()} kWh transferred. +${(_transferKwh * 15).toInt()} EcoCredits awarded!",
            style: const TextStyle(color: AppleLiquidColors.natureEmerald, fontWeight: FontWeight.bold),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final durationMin = ((_transferKwh / 22.0) * 60.0).round();
    final ecoCredits = (_transferKwh * 15).toInt();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "V2V Energy Sharing",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppleLiquidColors.textHeadline),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Peer-to-peer mobile DC charging",
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
                  "P2P LINK SECURED",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppleLiquidColors.natureEmerald),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. CAR-TO-CAR STAGE CARD
          LiquidGlassCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Donor (Hyundai Ioniq 5)
                    _carPod(
                      model: _donorModel,
                      role: "Peer Donor",
                      batteryPct: _donorBattery,
                      color: AppleLiquidColors.natureEmerald,
                    ),

                    // Sunlit Energy Stream Conduit
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _beamController,
                              builder: (context, child) {
                                return Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Align(
                                    alignment: Alignment(-1.0 + (_beamController.value * 2.0), 0.0),
                                    child: Container(
                                      width: 32,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.transparent, AppleLiquidColors.natureLeaf, Colors.transparent],
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: const [
                                          BoxShadow(color: AppleLiquidColors.natureLeaf, blurRadius: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "22 kW Mobile DC",
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppleLiquidColors.textSub),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Receiver (Tata Nexon EV)
                    _carPod(
                      model: "Tata Nexon EV",
                      role: "Your Vehicle",
                      batteryPct: p.batteryPct,
                      color: AppleLiquidColors.natureLeaf,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.near_me, size: 14, color: AppleLiquidColors.natureEmerald),
                        const SizedBox(width: 4),
                        Text("Proximity: ${_proximityKm} km away", style: const TextStyle(fontSize: 11, color: AppleLiquidColors.textSub)),
                      ],
                    ),
                    const Text(
                      "P2P Link Secured",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppleLiquidColors.natureEmerald),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. KWH TRANSFER VOLUME SLIDER CARD
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Transfer Energy", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                    Text(
                      "${_transferKwh.toInt()} kWh",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppleLiquidColors.natureEmerald),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LiquidMorphingSlider(
                  value: _transferKwh,
                  min: 3.0,
                  max: 25.0,
                  onChanged: (val) {
                    setState(() => _transferKwh = val);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TIME REQUIRED", style: TextStyle(fontSize: 9, color: AppleLiquidColors.textCaption, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text("~${durationMin} min", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppleLiquidColors.textHeadline)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ECOCREDITS REWARD", style: TextStyle(fontSize: 9, color: AppleLiquidColors.textCaption, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text("+${ecoCredits} Pts", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppleLiquidColors.natureEmerald)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TactileSpringButton(
                  onTap: _isTransferring ? () {} : _executeTransfer,
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
                    child: Center(
                      child: _isTransferring
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "EXECUTE V2V POWER TRANSFER",
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

  Widget _carPod({required String model, required String role, required double batteryPct, required Color color}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: CircularProgressIndicator(
                value: (batteryPct / 100.0).clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              "${batteryPct.toInt()}%",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppleLiquidColors.textHeadline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(model, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
        Text(role, style: const TextStyle(fontSize: 10, color: AppleLiquidColors.textCaption)),
      ],
    );
  }
}
