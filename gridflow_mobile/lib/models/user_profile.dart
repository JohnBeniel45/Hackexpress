class UserProfile {
  String userId;
  String vehicleModel;
  String vehicleType; // Sedan, SUV, Hatchback, Ambulance
  double batteryPct;
  String membership; // normal, premium, emergency_priority
  double lat;
  double lon;
  int ecoCredits;

  UserProfile({
    this.userId = "user_driver_01",
    this.vehicleModel = "Tata Nexon EV Max",
    this.vehicleType = "Sedan",
    this.batteryPct = 28.0,
    this.membership = "normal",
    this.lat = 12.9716,
    this.lon = 77.5946,
    this.ecoCredits = 120,
  });

  bool get isEmergency =>
      vehicleType.toLowerCase() == "ambulance" || batteryPct <= 10.0;

  String get priorityTierLabel {
    if (isEmergency) return "URGENT LEAPFROG";
    if (membership.toLowerCase() == "premium") return "PREMIUM PRIORITY";
    return "STANDARD FCFS";
  }

  double get estimatedRangeKm => (batteryPct / 100.0) * 350.0;
}
