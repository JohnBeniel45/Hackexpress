class Reservation {
  final String reservationId;
  final String userId;
  final int stationId;
  final String stationName;
  final String slotTime;
  final String status;
  final String priorityTier;
  final int chargerId;
  final int durationMinutes;
  final String vehicleType;
  final String qrPassCode;
  final String message;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.slotTime,
    required this.status,
    required this.priorityTier,
    required this.chargerId,
    this.durationMinutes = 30,
    this.vehicleType = "Sedan",
    required this.qrPassCode,
    required this.message,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservation_id'] as String,
      userId: json['user_id'] as String? ?? 'user_01',
      stationId: json['station_id'] as int,
      stationName: json['station_name'] as String? ?? 'EV Station',
      slotTime: json['slot_time'] as String,
      status: json['status'] as String? ?? 'confirmed',
      priorityTier: json['priority_tier'] as String? ?? 'NORMAL',
      chargerId: json['charger_id'] as int? ?? 1,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      vehicleType: json['vehicle_type'] as String? ?? 'Sedan',
      qrPassCode: json['qr_pass_code'] as String? ?? 'PASS',
      message: json['message'] as String? ?? 'Booking Confirmed',
    );
  }
}
