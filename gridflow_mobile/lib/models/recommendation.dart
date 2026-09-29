import 'station.dart';

class StationScoreBreakdown {
  final int stationId;
  final String stationName;
  final double totalScore;
  final double distanceKm;
  final double distanceScore;
  final double waitTimeMin;
  final double waitScore;
  final double gridLoad;
  final double gridPenalty;
  final double batteryUrgencyBoost;
  final String priorityTier;

  StationScoreBreakdown({
    required this.stationId,
    required this.stationName,
    required this.totalScore,
    required this.distanceKm,
    required this.distanceScore,
    required this.waitTimeMin,
    required this.waitScore,
    required this.gridLoad,
    required this.gridPenalty,
    required this.batteryUrgencyBoost,
    required this.priorityTier,
  });

  factory StationScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return StationScoreBreakdown(
      stationId: json['station_id'] as int,
      stationName: json['station_name'] as String? ?? '',
      totalScore: (json['total_score'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      distanceScore: (json['distance_score'] as num).toDouble(),
      waitTimeMin: (json['wait_time_min'] as num).toDouble(),
      waitScore: (json['wait_score'] as num).toDouble(),
      gridLoad: (json['grid_load'] as num).toDouble(),
      gridPenalty: (json['grid_penalty'] as num).toDouble(),
      batteryUrgencyBoost: (json['battery_urgency_boost'] as num).toDouble(),
      priorityTier: json['priority_tier'] as String? ?? 'NORMAL',
    );
  }
}

class RecommendationResult {
  final Station recommendedStation;
  final StationScoreBreakdown scoreBreakdown;
  final List<Station> alternativeStations;
  final String priorityLevel;
  final String aiRationale;

  RecommendationResult({
    required this.recommendedStation,
    required this.scoreBreakdown,
    required this.alternativeStations,
    required this.priorityLevel,
    required this.aiRationale,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    return RecommendationResult(
      recommendedStation: Station.fromJson(json['recommended_station']),
      scoreBreakdown: StationScoreBreakdown.fromJson(json['score_breakdown']),
      alternativeStations: (json['alternative_stations'] as List<dynamic>?)
              ?.map((e) => Station.fromJson(e))
              .toList() ??
          [],
      priorityLevel: json['priority_level'] as String? ?? 'NORMAL',
      aiRationale: json['ai_rationale'] as String? ?? '',
    );
  }
}
