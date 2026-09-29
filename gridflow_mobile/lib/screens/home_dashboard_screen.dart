import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/station.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class HomeDashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(int) onNavigateTab;
  final VoidCallback onProfileChanged;

  const HomeDashboardScreen({
    Key? key,
    required this.profile,
    required this.onNavigateTab,
    required this.onProfileChanged,
  }) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<Station> _nearbyStations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    setState(() => _isLoading = true);
    final stations = await ApiService.getStations(
      lat: widget.profile.lat,
      lon: widget.profile.lon,
      radius: 15.0,
    );
    if (mounted) {
      setState(() {
        _nearbyStations = stations;
        _isLoading = false;
      });
    }
  }

  Color _getBatteryColor(double pct) {
    if (pct <= 10) return AppColors.fullRed;
    if (pct <= 25) return AppColors.emergencyOrange;
    if (pct <= 50) return AppColors.busyYellow;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final batColor = _getBatteryColor(p.batteryPct);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("GridFlow AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Bengaluru Smart EV Grid", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text("${p.ecoCredits} pts", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearby,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Emergency Leapfrog Alert Banner (if battery <= 10% or Ambulance)
              if (p.isEmergency)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.fullRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fullRed, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.fullRed, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.vehicleType.toLowerCase() == "ambulance"
                                  ? "🚨 AMBULANCE EMERGENCY ACTIVE"
                                  : "⚠️ CRITICAL BATTERY: ${p.batteryPct.toInt()}%",
                              style: const TextStyle(color: AppColors.fullRed, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Leapfrog priority enabled. You will jump the queue at any station or can request urgent V2V peer charge.",
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 2. Battery SOC & Vehicle Dashboard Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.vehicleModel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: p.isEmergency ? AppColors.fullRed : (p.membership == "premium" ? AppColors.secondary : AppColors.surfaceElevated),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p.priorityTierLabel,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Range: ~${p.estimatedRangeKm.toInt()} km", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          // Circular SOC Ring
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: CircularProgressIndicator(
                                  value: p.batteryPct / 100.0,
                                  strokeWidth: 7,
                                  backgroundColor: AppColors.surfaceElevated,
                                  valueColor: AlwaysStoppedAnimation<Color>(batColor),
                                ),
                              ),
                              Text(
                                "${p.batteryPct.toInt()}%",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: batColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 8),
                      // Interactive Battery Slider for Test/Demo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Simulate Battery Level:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text("${p.batteryPct.toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: batColor)),
                        ],
                      ),
                      Slider(
                        value: p.batteryPct,
                        min: 3.0,
                        max: 100.0,
                        divisions: 97,
                        activeColor: batColor,
                        inactiveColor: AppColors.surfaceElevated,
                        onChanged: (val) {
                          setState(() {
                            p.batteryPct = double.parse(val.toStringAsFixed(1));
                          });
                          widget.onProfileChanged();
                        },
                      ),
                      // Vehicle Type & Membership Controls
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: p.vehicleType,
                              decoration: const InputDecoration(
                                labelText: "Vehicle Type",
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              items: ["Sedan", "SUV", "Hatchback", "Ambulance"].map((t) {
                                return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => p.vehicleType = val);
                                  widget.onProfileChanged();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: p.membership,
                              decoration: const InputDecoration(
                                labelText: "Tier",
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: "normal", child: Text("Normal (FCFS)", style: TextStyle(fontSize: 13))),
                                const DropdownMenuItem(value: "premium", child: Text("Premium VIP", style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => p.membership = val);
                                  widget.onProfileChanged();
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. One-Tap Main Action CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNavigateTab(2), // Navigate to Recommender Tab
                  icon: const Icon(Icons.auto_awesome, color: Colors.black),
                  label: const Text("FIND OPTIMAL CHARGER (AI)"),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Action Buttons (V2V & Analytics)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onNavigateTab(3), // V2V
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text("V2V Share"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onNavigateTab(4), // Analytics
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text("Grid Impact"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Live Stations Nearby Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nearby EV Stations", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1),
                    child: const Text("View Map", style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else
                ..._nearbyStations.take(4).map((st) => _buildStationCard(st, p)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(Station st, UserProfile p) {
    Color statusColor;
    if (st.status == "maintenance") {
      statusColor = AppColors.textTertiary;
    } else if (st.chargersAvailable == 0) {
      statusColor = AppColors.fullRed;
    } else if (st.chargersAvailable <= 2) {
      statusColor = AppColors.busyYellow;
    } else {
      statusColor = AppColors.availableGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Icon(Icons.ev_station, color: statusColor, size: 24),
        ),
        title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${st.chargersAvailable}/${st.chargersTotal} plugs free",
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text("• ${st.powerKw.toInt()} kW DC", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 8),
                Text("• ${st.distanceKm ?? 2.5} km", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text("Est. wait: ~${st.predictedWaitMin.toStringAsFixed(1)} min", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 10),
                const Icon(Icons.electric_meter_outlined, size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text("Grid: ${(st.gridLoad * 100).toInt()}%", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        onTap: () => widget.onNavigateTab(2),
      ),
    );
  }
}
