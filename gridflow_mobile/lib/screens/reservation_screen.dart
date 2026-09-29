import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/station.dart';
import '../models/user_profile.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ReservationScreen extends StatefulWidget {
  final Station station;
  final UserProfile profile;
  final VoidCallback onBookingComplete;

  const ReservationScreen({
    Key? key,
    required this.station,
    required this.profile,
    required this.onBookingComplete,
  }) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _selectedSlotIndex = 0;
  int _durationMinutes = 30;
  bool _isSubmitting = false;
  Reservation? _confirmedReservation;

  List<String> get _availableSlots {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final slotTime = now.add(Duration(minutes: (i + 1) * 15));
      return DateFormat('HH:mm').format(slotTime);
    });
  }

  Future<void> _handleBookSlot() async {
    setState(() => _isSubmitting = true);
    final slot = _availableSlots[_selectedSlotIndex];
    final fullSlotStr = "${DateFormat('yyyy-MM-dd').format(DateTime.now())} $slot";

    final res = await ApiService.reserveSlot(
      userId: widget.profile.userId,
      stationId: widget.station.id,
      slotTime: fullSlotStr,
      vehicleType: widget.profile.vehicleType,
      batteryPct: widget.profile.batteryPct,
      membership: widget.profile.membership,
      durationMinutes: _durationMinutes,
    );

    if (mounted) {
      setState(() {
        _confirmedReservation = res;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmedReservation != null) {
      return _buildConfirmationView(_confirmedReservation!);
    }

    final p = widget.profile;
    final isUrgent = p.isEmergency;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Charging Bay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station summary header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.ev_station, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.station.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(widget.station.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.station.chargersAvailable} bays free • ${widget.station.powerKw.toInt()} kW DC Fast",
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Priority Preemption Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUrgent
                    ? AppColors.fullRed.withOpacity(0.15)
                    : (p.membership == "premium" ? AppColors.secondary.withOpacity(0.15) : AppColors.surfaceElevated),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUrgent
                      ? AppColors.fullRed
                      : (p.membership == "premium" ? AppColors.secondary : AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUrgent ? Icons.bolt_outlined : Icons.verified_user,
                    color: isUrgent
                        ? AppColors.fullRed
                        : (p.membership == "premium" ? AppColors.secondary : AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrgent ? "EMERGENCY LEAPFROG SCHEDULING" : "PRIORITY TIER: ${p.priorityTierLabel}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isUrgent
                                ? AppColors.fullRed
                                : (p.membership == "premium" ? AppColors.secondary : AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          isUrgent
                              ? "Preempts regular queue. Automatically routed to Emergency Fast Bay #1."
                              : (p.membership == "premium"
                                  ? "Zero queue wait with reserved Premium Bay allocation."
                                  : "Standard FCFS time slot allocation with guaranteed lock-in."),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 15-Minute Slot Selector
            const Text("Select 15-Minute Arrival Slot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_availableSlots.length, (idx) {
                final selected = _selectedSlotIndex == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSlotIndex = idx),
                    child: Container(
                      margin: EdgeInsets.only(right: idx == _availableSlots.length - 1 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _availableSlots[idx],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: selected ? Colors.black : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            idx == 0 ? "Next Ready" : "+${(idx + 1) * 15}m",
                            style: TextStyle(fontSize: 10, color: selected ? Colors.black87 : AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 22),

            // Session Duration Picker
            const Text("Expected Charging Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [15, 30, 45, 60].map((dur) {
                final selected = _durationMinutes == dur;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _durationMinutes = dur),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryVariant : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? AppColors.primaryVariant : AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          "$dur min",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: selected ? Colors.black : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 26),

            // Tariff & Energy estimate
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _priceRow("Estimated Energy", "${((widget.station.powerKw * (_durationMinutes / 60.0)) * 0.85).toInt()} kWh"),
                    const SizedBox(height: 8),
                    _priceRow("Station Rate", "₹${widget.station.pricePerKwh} / kWh"),
                    const Divider(color: AppColors.border, height: 16),
                    _priceRow(
                      "Estimated Total",
                      "₹${(((widget.station.powerKw * (_durationMinutes / 60.0)) * 0.85) * widget.station.pricePerKwh).toInt()}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleBookSlot,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        isUrgent ? "DISPATCH EMERGENCY LEAPFROG SLOT" : "CONFIRM & LOCK CHARGING BAY",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationView(Reservation res) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmed")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.availableGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text("CHARGING BAY LOCKED", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(res.message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),

              // Digital Pass Ticket
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("GRIDFLOW DIGITAL PASS", style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
                          Text(res.reservationId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const Divider(color: AppColors.border, height: 24),
                      // Simulated QR Code
                      Container(
                        width: 130,
                        height: 130,
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_2, size: 90, color: Colors.black),
                              Text(res.qrPassCode, style: const TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _passDetail("STATION", res.stationName),
                      _passDetail("ASSIGNED BAY", "Charger Bay #${res.chargerId} (DC Fast)"),
                      _passDetail("SLOT TIME", res.slotTime),
                      _passDetail("PRIORITY CLASS", res.priorityTier),
                      _passDetail("DURATION", "${res.durationMinutes} minutes"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onBookingComplete,
                  child: const Text("RETURN TO DASHBOARD"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _passDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(color: isBold ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: isBold ? 15 : 13)),
      ],
    );
  }
}
