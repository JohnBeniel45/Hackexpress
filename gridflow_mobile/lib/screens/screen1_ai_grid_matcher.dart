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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title & Priority Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AI Grid & Matcher",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppleLiquidColors.platinum100,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppleLiquidColors.crimsonAlert.withOpacity(0.15)
                      : AppleLiquidColors.forestEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUrgent
                        ? AppleLiquidColors.crimsonAlert
                        : AppleLiquidColors.forestEmerald,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isUrgent ? "LEAPFROG ARMED" : "GRID BALANCED",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isUrgent
                        ? AppleLiquidColors.crimsonAlert
                        : AppleLiquidColors.forestPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. LOCAL SUBSTATION GRID TELEMETRY CARD
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
                        const Text(
                          "LOCAL SUBSTATION STRESS",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppleLiquidColors.silver400, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text(
                              "54.2%",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'monospace'),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppleLiquidColors.forestEmerald.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "STABLE GREEN",
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppleLiquidColors.forestPrimary),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("DISCOM Feeder", style: TextStyle(fontSize: 10, color: AppleLiquidColors.silver400)),
                        Text("BESCOM 11kV Node", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppleLiquidColors.silver200)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol("Peak Spike Risk", "0.12 (LOW)", AppleLiquidColors.forestEmerald),
                      _metricCol("Renewable Mix", "38.5% Solar", AppleLiquidColors.forestPrimary),
                      _metricCol("Active Plugs", "34 / 42 Online", AppleLiquidColors.silver200),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. VEHICLE SOC & REACTIVE SLIDER CARD
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
                        Text(p.vehicleModel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text("Range remaining: ~${p.estimatedRangeKm.toInt()} km", style: const TextStyle(fontSize: 11, color: AppleLiquidColors.silver400)),
                      ],
                    ),
                    Text(
                      "${p.batteryPct.toInt()}%",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.forestPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LiquidMorphingSlider(
                  value: p.batteryPct,
                  min: 4.0,
                  max: 100.0,
                  activeColor: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.forestPrimary,
                  onChanged: (val) {
                    setState(() {
                      p.batteryPct = val;
                    });
                    widget.onProfileChanged();
                  },
                ),
                if (isUrgent)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppleLiquidColors.crimsonAlert.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppleLiquidColors.crimsonAlert, width: 0.5),
                    ),
                    child: const Row(
                      children: [
                        Text("🚨", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Emergency Leapfrog active: queue preemption enabled at Bay #1.",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFCA5A5)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 3. OPTIMAL CHARGER CARD (POWERED BY XGBOOST)
          if (_recommendation != null)
            LiquidGlassCard(
              borderColor: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.glassBorderGreen,
              backgroundColor: const Color(0xCC101622),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.forestEmerald).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUrgent ? "🚨 EMERGENCY LEAPFROG BAY" : "✨ TOP AI RECOMMENDATION",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.forestPrimary,
                          ),
                        ),
                      ),
                      Text(
                        "${_recommendation!.scoreBreakdown.totalScore.toInt()}/100 Match",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: isUrgent ? AppleLiquidColors.crimsonAlert : AppleLiquidColors.forestPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_recommendation!.recommendedStation.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text(_recommendation!.recommendedStation.address, style: const TextStyle(fontSize: 11, color: AppleLiquidColors.silver400)),
                  const SizedBox(height: 12),
                  // Telemetry Metrics
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricCol("Distance", "${_recommendation!.recommendedStation.distanceKm ?? 3.8} km", Colors.white),
                        _metricCol("XGBoost Wait", "~${_recommendation!.recommendedStation.predictedWaitMin.toStringAsFixed(1)} min", AppleLiquidColors.forestPrimary),
                        _metricCol("DC Power", "${_recommendation!.recommendedStation.powerKw.toInt()} kW", Colors.white),
                        _metricCol("Grid Load", "${(_recommendation!.recommendedStation.gridLoad * 100).toInt()}%", AppleLiquidColors.silver200),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // AI Rationale
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppleLiquidColors.forestPrimary, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _recommendation!.aiRationale,
                            style: const TextStyle(fontSize: 11, color: AppleLiquidColors.silver200, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TactileSpringButton(
                    onTap: () => widget.onReserve(_recommendation!.recommendedStation),
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
                      child: Center(
                        child: Text(
                          isUrgent ? "DISPATCH PRIORITY EMERGENCY BAY" : "RESERVE 15-MIN BAY SLOT",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF042517)),
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
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 9, color: AppleLiquidColors.silver400)),
      ],
    );
  }
}
