import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/target_location.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final TargetLocation _target = TargetLocation.defaultTarget;
  
  int _gpsRequestCount = 0;
  DateTime? _lastUpdate;
  
  Position? get currentPosition => _currentPosition;
  TargetLocation get target => _target;
  int get gpsRequestCount => _gpsRequestCount;
  
  // Calculate distance to target in meters
  double? get distanceToTarget {
    if (_currentPosition == null) return null;
    return _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _target.latitude,
      _target.longitude,
    );
  }
  
  // Check if accuracy is good enough for camera activation (<5 meters)
  bool get isAccuracyGoodEnough {
    if (_currentPosition == null) return false;
    return _currentPosition!.accuracy < 5.0;
  }
  
  // Get adaptive update interval based on distance (energy efficiency)
  Duration get adaptiveInterval {
    final distance = distanceToTarget;
    if (distance == null) return const Duration(seconds: 5);
    
    // Closer = more frequent updates
    if (distance > 100) return const Duration(seconds: 10);  // Far
    if (distance > 50) return const Duration(seconds: 5);    // Medium
    if (distance > 10) return const Duration(seconds: 3);    // Close
    return const Duration(seconds: 1);                        // Very close
  }
  
  // Start listening to location updates with adaptive sampling
  Future<void> startLocationUpdates() async {
    _positionStream?.cancel();
    
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters minimum
    );
    
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _handlePositionUpdate(position);
    });
  }
  
  void _handlePositionUpdate(Position position) {
    final now = DateTime.now();
    
    // Check if we should update based on adaptive interval
    if (_lastUpdate != null) {
      final elapsed = now.difference(_lastUpdate!);
      if (elapsed < adaptiveInterval) {
        return; // Skip this update for energy efficiency
      }
    }
    
    _currentPosition = position;
    _lastUpdate = now;
    _gpsRequestCount++;
    notifyListeners();
  }
  
  // Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      _gpsRequestCount++;
      notifyListeners();
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }
  
  // Calculate distance using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  
  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
