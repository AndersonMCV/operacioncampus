import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/target_location.dart';

class AssetLoaderService {
  // Singleton pattern
  static final AssetLoaderService _instance = AssetLoaderService._internal();
  factory AssetLoaderService() => _instance;
  AssetLoaderService._internal();

  bool _areAssetsLoaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  bool get areAssetsLoaded => _areAssetsLoaded;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;

  final StreamController<double> _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  /// Checks if we are close enough to the target to start downloading assets.
  /// Returns [true] if assets are already loaded or if download starts/completes.
  Future<bool> checkAndLoadAssets(Position currentPosition, TargetLocation target) async {
    if (_areAssetsLoaded) return true;
    if (_isDownloading) return false; // Already working on it

    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      target.latitude,
      target.longitude,
    );

    // LAZY LOADING STRATEGY:
    // Only download heavy 3D models when user is within 50 meters of the target.
    // This saves bandwidth (approx 50MB per model) and RAM for users who aren't nearby.
    if (distance <= 50) {
      debugPrint('User is within 50m ($distance m). Starting asset download...');
      await _simulateDownload();
      return true;
    } else {
      debugPrint('User is too far ($distance m) for asset download.');
      return false;
    }
  }

  /// Simulates a large file download (e.g., 50MB .glb file)
  Future<void> _simulateDownload() async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    _progressController.add(0.0);

    // Simulate 3 seconds of download time
    const steps = 20;
    for (int i = 0; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _downloadProgress = i / steps;
      _progressController.add(_downloadProgress);
    }

    _areAssetsLoaded = true;
    _isDownloading = false;
    _progressController.add(1.0);
    debugPrint('Assets downloaded and cached in memory.');
  }
  
  void reset() {
    _areAssetsLoaded = false;
    _isDownloading = false;
    _downloadProgress = 0.0;
  }
}
