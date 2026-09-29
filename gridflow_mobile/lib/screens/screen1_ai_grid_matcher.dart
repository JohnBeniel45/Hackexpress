import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../components/liquid_glass_card.dart';
import '../components/liquid_morphing_slider.dart';
import '../animations/spring_physics.dart';
import '../models/user_profile.dart';
import '../models/station.dart';
import '../models/recommendation.dart';
import '../services/api_service.dart';

class Screen1AiGridMatcher extends StatefulWidget {
  final UserProfile profile;
  final Function(Station) onReserve;
  final VoidCallback onProfileChanged;

  const Screen1AiGridMatcher({
    Key? key,
    required this.profile,
    required this.onReserve,
    required this.onProfileChanged,
  }) : super(key: key);

  @override
  State<Screen1AiGridMatcher> createState() => _Screen1AiGridMatcherState();
}

class _Screen1AiGridMatcherState extends State<Screen1AiGridMatcher> {
  RecommendationResult? _recommendation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendation();
  }

  Future<void> _fetchRecommendation() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getRecommendation(widget.profile);
    if (mounted) {
      setState(() {
        _recommendation = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final isUrgent = p.isEmergency;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90), // 90px bottom clearance for floating dock
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with generous breathing room
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Grid & Charger Matcher",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppleLiquidColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Clean energy coordination & XGBoost dispatch",
                    style: TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFEE2E2) : AppleLiquidColors.mintContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUrgent ? const Color(0xFFFCA5A5) : AppleLiquidColors.natureMint,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isUrgent ? "🚨 LEAPFROG ARMED" : "OPTIMAL GRID",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. HIGH-IMPACT STAT: SUBSTATION GRID HEALTH
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LOCAL SUBSTATION HEALTH",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppleLiquidColors.textCaption, letterSpacing: 0.6),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "98.4%",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        fontFamily: 'monospace',
                        color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppleLiquidColors.mintContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "STABLE & GREEN",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppleLiquidColors.natureEmerald),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Feeder: BESCOM 11kV Corridor", style: TextStyle(fontSize: 11, color: AppleLiquidColors.textSub)),
                    Text("Spike Risk: 0.08 (Minimal)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppleLiquidColors.natureEmerald)),
                  ],
                ),
              ],
            ),
          ),

          // 2. BATTERY STATE SLIDER
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
                        Text(p.vehicleModel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                        Text("Range remaining: ~${p.estimatedRangeKm.toInt()} km", style: const TextStyle(fontSize: 11, color: AppleLiquidColors.textCaption)),
                      ],
                    ),
                    Text(
                      "${p.batteryPct.toInt()}%",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LiquidMorphingSlider(
                  value: p.batteryPct,
                  min: 4.0,
                  max: 100.0,
                  activeColor: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                  onChanged: (val) {
                    setState(() => p.batteryPct = val);
                    widget.onProfileChanged();
                  },
                ),
                if (isUrgent)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
                    ),
                    child: Row(
                      children: const [
                        Text("🚨", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Critical battery (<=10%). Normal queue preempted at Bay #1.",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 3. OPTIMAL AI RECOMMENDATION CARD
          if (_recommendation != null)
            LiquidGlassCard(
              borderColor: isUrgent ? const Color(0xFFFCA5A5) : AppleLiquidColors.glassBorderGreen,
              backgroundColor: const Color(0xF2FFFFFF), // 95% pristine pearl white
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isUrgent ? const Color(0xFFFEE2E2) : AppleLiquidColors.mintContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUrgent ? "🚨 EMERGENCY BAY DISPATCH" : "✨ OPTIMAL CHARGER MATCH",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppleLiquidColors.mintContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_recommendation!.scoreBreakdown.totalScore.toInt()}/100 Match",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.natureEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_recommendation!.recommendedStation.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppleLiquidColors.textHeadline)),
                  Text(_recommendation!.recommendedStation.address, style: const TextStyle(fontSize: 12, color: AppleLiquidColors.textCaption)),
                  const SizedBox(height: 14),
                  // Clean High-Impact Stats Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricCol("DISTANCE", "${_recommendation!.recommendedStation.distanceKm ?? 3.8} km", AppleLiquidColors.textHeadline),
                        _metricCol("XGBOOST WAIT", "~${_recommendation!.recommendedStation.predictedWaitMin.toStringAsFixed(1)} min", AppleLiquidColors.natureEmerald),
                        _metricCol("DC POWER", "${_recommendation!.recommendedStation.powerKw.toInt()} kW", AppleLiquidColors.textHeadline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TactileSpringButton(
                    onTap: () => widget.onReserve(_recommendation!.recommendedStation),
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
                        child: Text(
                          isUrgent ? "DISPATCH EMERGENCY BAY #1" : "RESERVE 15-MIN BAY",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
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

  Widget _metricCol(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 9, color: AppleLiquidColors.textCaption)),
      ],
    );
  }
}
