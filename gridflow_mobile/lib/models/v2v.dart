class V2VPeer {
  final String userId;
  final String vehicleModel;
  final double batteryPct;
  final double lat;
  final double lon;
  final double distanceKm;
  final String role; // donor, receiver
  final double maxShareableKwh;

  V2VPeer({
    required this.userId,
    required this.vehicleModel,
    required this.batteryPct,
    required this.lat,
    required this.lon,
    required this.distanceKm,
    required this.role,
    required this.maxShareableKwh,
  });

  factory V2VPeer.fromJson(Map<String, dynamic> json) {
    return V2VPeer(
      userId: json['user_id'] as String,
      vehicleModel: json['vehicle_model'] as String? ?? 'EV',
      batteryPct: (json['battery_pct'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      role: json['role'] as String,
      maxShareableKwh: (json['max_shareable_kwh'] as num).toDouble(),
    );
  }
}

class V2VTransferResult {
  final String sessionId;
  final String status;
  final String donorUserId;
  final String receiverUserId;
  final double kwhTransferred;
  final double donorInitialPct;
  final double donorFinalPct;
  final double receiverInitialPct;
  final double receiverFinalPct;
  final double durationMinutes;
  final int greenCreditsEarned;
  final double carbonOffsetKg;
  final String message;

  V2VTransferResult({
    required this.sessionId,
    required this.status,
    required this.donorUserId,
    required this.receiverUserId,
    required this.kwhTransferred,
    required this.donorInitialPct,
    required this.donorFinalPct,
    required this.receiverInitialPct,
    required this.receiverFinalPct,
    required this.durationMinutes,
    required this.greenCreditsEarned,
    required this.carbonOffsetKg,
    required this.message,
  });

  factory V2VTransferResult.fromJson(Map<String, dynamic> json) {
    return V2VTransferResult(
      sessionId: json['session_id'] as String,
      status: json['status'] as String,
      donorUserId: json['donor_user_id'] as String,
      receiverUserId: json['receiver_user_id'] as String,
      kwhTransferred: (json['kwh_transferred'] as num).toDouble(),
      donorInitialPct: (json['donor_initial_pct'] as num).toDouble(),
      donorFinalPct: (json['donor_final_pct'] as num).toDouble(),
      receiverInitialPct: (json['receiver_initial_pct'] as num).toDouble(),
      receiverFinalPct: (json['receiver_final_pct'] as num).toDouble(),
      durationMinutes: (json['duration_minutes'] as num).toDouble(),
      greenCreditsEarned: json['green_credits_earned'] as int,
      carbonOffsetKg: (json['carbon_offset_kg'] as num).toDouble(),
      message: json['message'] as String,
    );
  }
}
