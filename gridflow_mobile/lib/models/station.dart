class Station {
  final int id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lon;
  final int chargersTotal;
  final int chargersAvailable;
  final String status;
  final double gridLoad;
  final double powerKw;
  final List<String> connectorTypes;
  final double pricePerKwh;
  final int queueLength;
  final double predictedWaitMin;
  final String operator;
  final double? distanceKm;

  Station({
    required this.id,
    required this.name,
    required this.address,
    this.city = "Bengaluru",
    required this.lat,
    required this.lon,
    required this.chargersTotal,
    required this.chargersAvailable,
    required this.status,
    required this.gridLoad,
    this.powerKw = 60.0,
    required this.connectorTypes,
    this.pricePerKwh = 14.5,
    this.queueLength = 0,
    this.predictedWaitMin = 0.0,
    this.operator = "GridFlow Hub",
    this.distanceKm,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'Bengaluru Metro Area',
      city: json['city'] as String? ?? 'Bengaluru',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      chargersTotal: json['chargers_total'] as int? ?? 4,
      chargersAvailable: json['chargers_available'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      gridLoad: (json['grid_load'] as num?)?.toDouble() ?? 0.5,
      powerKw: (json['power_kw'] as num?)?.toDouble() ?? 60.0,
      connectorTypes: (json['connector_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['CCS2', 'Type 2 AC'],
      pricePerKwh: (json['price_per_kwh'] as num?)?.toDouble() ?? 14.5,
      queueLength: json['queue_length'] as int? ?? 0,
      predictedWaitMin: (json['predicted_wait_min'] as num?)?.toDouble() ?? 0.0,
      operator: json['operator'] as String? ?? 'GridFlow Partner',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Station copyWith({
    double? distanceKm,
    int? chargersAvailable,
    int? queueLength,
    double? predictedWaitMin,
  }) {
    return Station(
      id: id,
      name: name,
      address: address,
      city: city,
      lat: lat,
      lon: lon,
      chargersTotal: chargersTotal,
      chargersAvailable: chargersAvailable ?? this.chargersAvailable,
      status: status,
      gridLoad: gridLoad,
      powerKw: powerKw,
      connectorTypes: connectorTypes,
      pricePerKwh: pricePerKwh,
      queueLength: queueLength ?? this.queueLength,
      predictedWaitMin: predictedWaitMin ?? this.predictedWaitMin,
      operator: operator,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
