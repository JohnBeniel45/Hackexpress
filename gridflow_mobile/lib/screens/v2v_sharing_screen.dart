import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/v2v.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class V2VSharingScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onStateUpdated;

  const V2VSharingScreen({
    Key? key,
    required this.profile,
    required this.onStateUpdated,
  }) : super(key: key);

  @override
  State<V2VSharingScreen> createState() => _V2VSharingScreenState();
}

class _V2VSharingScreenState extends State<V2VSharingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _userRole = "receiver"; // receiver or donor
  double _transferKwh = 10.0;
  bool _isTransferring = false;
  V2VTransferResult? _lastResult;

  // Simulated peer vehicle
  double _peerBatteryPct = 92.0;
  String _peerModel = "Hyundai Ioniq 5 (72.6 kWh)";
  String _peerDistance = "0.4 km away";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _syncRoleFromBattery();
  }

  void _syncRoleFromBattery() {
    if (widget.profile.batteryPct <= 20) {
      _userRole = "receiver";
    } else {
      _userRole = "donor";
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startTransfer() async {
    setState(() => _isTransferring = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Animated pulse delay

    final res = await ApiService.transferEnergy(
      donorId: _userRole == "donor" ? widget.profile.userId : "peer_ioniq_01",
      receiverId: _userRole == "receiver" ? widget.profile.userId : "peer_nexon_02",
      kwh: _transferKwh,
    );

    if (mounted) {
      setState(() {
        _lastResult = res;
        _isTransferring = false;

        // Apply state changes to user profile
        if (_userRole == "receiver") {
          widget.profile.batteryPct = res.receiverFinalPct;
          _peerBatteryPct = res.donorFinalPct;
        } else {
          widget.profile.batteryPct = res.donorFinalPct;
          _peerBatteryPct = res.receiverFinalPct;
          widget.profile.ecoCredits += res.greenCreditsEarned;
        }
      });
      widget.onStateUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final isReceiver = _userRole == "receiver";

    return Scaffold(
      appBar: AppBar(
        title: const Text("V2V Energy Sharing"),
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
                Text("${p.ecoCredits} EcoCredits", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector: Donor vs Receiver
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _userRole = "receiver"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isReceiver ? AppColors.emergencyOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Need Charge (Receiver)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isReceiver ? Colors.black : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _userRole = "donor"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isReceiver ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Share Charge (Donor)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: !isReceiver ? Colors.black : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Car-to-Car Energy Beam Transfer Visualizer Card
            Card(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface,
                      (isReceiver ? AppColors.emergencyOrange : AppColors.primary).withOpacity(0.06),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Vehicle: Car A
                        _buildVehicleNode(
                          title: isReceiver ? "Peer Donor" : "Your EV (Donor)",
                          model: isReceiver ? _peerModel : p.vehicleModel,
                          batteryPct: isReceiver ? _peerBatteryPct : p.batteryPct,
                          color: AppColors.primary,
                          isDonor: true,
                        ),

                        // Animated Center Energy Beam
                        Expanded(
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _animController,
                                builder: (context, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(4, (i) {
                                      final active = ((_animController.value * 4).floor() == i);
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: active
                                              ? AppColors.primary
                                              : AppColors.textTertiary.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  "22 kW DC V2V",
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryVariant),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Vehicle: Car B
                        _buildVehicleNode(
                          title: isReceiver ? "Your EV (Receiver)" : "Peer Receiver",
                          model: isReceiver ? p.vehicleModel : "Stranded Auto / EV",
                          batteryPct: isReceiver ? p.batteryPct : 12.0,
                          color: AppColors.emergencyOrange,
                          isDonor: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 10),

                    // Peer distance info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.primaryVariant),
                            const SizedBox(width: 4),
                            Text("Matched Peer: $_peerDistance", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text(
                          "P2P Link Secured",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.availableGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Energy Transfer Amount Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Transfer Energy Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("${_transferKwh.toInt()} kWh", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: _transferKwh,
                      min: 3.0,
                      max: 25.0,
                      divisions: 22,
                      activeColor: isReceiver ? AppColors.emergencyOrange : AppColors.primary,
                      onChanged: (val) => setState(() => _transferKwh = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Est. Duration: ~${((_transferKwh / 22.0) * 60).toInt()} min", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text("Reward: +${(_transferKwh * 15).toInt()} EcoPoints", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Transfer Trigger Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isTransferring ? null : _startTransfer,
                icon: _isTransferring
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.bolt, color: Colors.black),
                label: Text(
                  _isTransferring
                      ? "PUMPING ENERGY OVER V2V LINK..."
                      : (isReceiver ? "REQUEST EMERGENCY PEER ENERGY" : "EXECUTE V2V POWER SHARE"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (_lastResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.availableGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.availableGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.availableGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "P2P Transfer Complete (${_lastResult!.sessionId})",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.availableGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_lastResult!.message, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Transferred: ${_lastResult!.kwhTransferred} kWh", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text("CO₂ Saved: ${_lastResult!.carbonOffsetKg} kg", style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleNode({
    required String title,
    required String model,
    required double batteryPct,
    required Color color,
    required bool isDonor,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(
                value: batteryPct / 100.0,
                strokeWidth: 6,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(isDonor ? Icons.battery_charging_full : Icons.battery_alert, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 6),
        Text("${batteryPct.toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(
          model.length > 14 ? "${model.substring(0, 14)}..." : model,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
