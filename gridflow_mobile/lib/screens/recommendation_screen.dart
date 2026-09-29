import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/recommendation.dart';
import '../models/station.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RecommendationScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(Station) onReserveStation;

  const RecommendationScreen({
    Key? key,
    required this.profile,
    required this.onReserveStation,
  }) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  RecommendationResult? _result;
  bool _isLoading = true;

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
        _result = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Charger Match"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecommendation,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Evaluating live queues & grid stress with XGBoost...",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. AI Recommendation Card
                  _buildChampionCard(_result!),

                  const SizedBox(height: 20),

                  // 2. Score Breakdown Card
                  _buildBreakdownCard(_result!.scoreBreakdown),

                  const SizedBox(height: 24),

                  // 3. Alternative Stations
                  const Text("Alternative Stations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._result!.alternativeStations.map((st) => _buildAlternativeTile(st)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildChampionCard(RecommendationResult res) {
    final st = res.recommendedStation;
    final isUrgent = res.priorityLevel.contains("URGENT") || widget.profile.isEmergency;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? AppColors.fullRed : AppColors.primary,
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              (isUrgent ? AppColors.fullRed : AppColors.primary).withOpacity(0.08),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.fullRed : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(isUrgent ? Icons.emergency : Icons.stars, color: Colors.black, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isUrgent ? "EMERGENCY LEAPFROG" : "TOP AI MATCH",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${res.scoreBreakdown.totalScore.toInt()}/100 Match",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isUrgent ? AppColors.fullRed : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(st.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Text(st.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricBadge(Icons.navigation, "${st.distanceKm ?? 3.2} km", "Distance"),
                _metricBadge(Icons.timer, "~${st.predictedWaitMin.toStringAsFixed(1)} min", "XGBoost Wait"),
                _metricBadge(Icons.bolt, "${st.powerKw.toInt()} kW", "Fast DC"),
                _metricBadge(Icons.electric_meter, "${(st.gridLoad * 100).toInt()}%", "Grid Load"),
              ],
            ),
            const SizedBox(height: 14),
            // Rationale explanation box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      res.aiRationale,
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => widget.onReserveStation(st),
                icon: const Icon(Icons.calendar_today, color: Colors.black, size: 18),
                label: const Text("RESERVE THIS BAY NOW"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(StationScoreBreakdown bd) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AI Scoring Factor Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _scoreBar("Proximity Score", bd.distanceScore, 35.0, AppColors.primaryVariant),
            _scoreBar("Wait-Time Minimization", bd.waitScore, 35.0, AppColors.primary),
            _scoreBar("Urgency & Priority Boost", bd.batteryUrgencyBoost, 35.0, AppColors.emergencyOrange),
            if (bd.gridPenalty > 0)
              _scoreBar("Grid Stress Penalty", bd.gridPenalty, 20.0, AppColors.fullRed, isPenalty: true),
          ],
        ),
      ),
    );
  }

  Widget _scoreBar(String label, double val, double maxVal, Color color, {bool isPenalty = false}) {
    final double pct = (val / maxVal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                "${isPenalty ? '-' : '+'}${val.toStringAsFixed(1)} pts",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeTile(Station st) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          "${st.chargersAvailable}/${st.chargersTotal} available • ~${st.predictedWaitMin.toStringAsFixed(1)} min wait • ${st.powerKw.toInt()} kW",
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: OutlinedButton(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
          onPressed: () => widget.onReserveStation(st),
          child: const Text("Select", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _metricBadge(IconData icon, String val, String title) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}
