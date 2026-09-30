import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/station.dart';

class LocationService {
  /// Prompts the user for GPS location permission and retrieves real-time device coordinates.
  static Future<Position?> requestAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if device location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Calculates real-world great-circle distance between two GPS coordinates in kilometers.
  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0; // Earth's radius in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (r * c * 10).round() / 10.0;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }

  /// Returns updated list of stations with dynamic real distances from the user's live coordinates.
  static List<Station> updateStationDistances(List<Station> stations, double userLat, double userLon) {
    final updated = stations.map((s) {
      final dist = calculateDistanceKm(userLat, userLon, s.lat, s.lon);
      return s.copyWith(distanceKm: dist);
    }).toList();

    updated.sort((a, b) => (a.distanceKm ?? 999.0).compareTo(b.distanceKm ?? 999.0));
    return updated;
  }
}
