import 'package:flutter/foundation.dart';

enum AppPhase {
  permissionsCheck,
  mapNavigation,
  mlDetection,
  arIntervention,
  completed,
}

class AppStateProvider extends ChangeNotifier {
  AppPhase _currentPhase = AppPhase.permissionsCheck;
  bool _locationPermissionGranted = false;
  bool _cameraPermissionGranted = false;
  bool _arInterventionCompleted = false;
  
  AppPhase get currentPhase => _currentPhase;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get arInterventionCompleted => _arInterventionCompleted;
  
  bool get allPermissionsGranted =>
      _locationPermissionGranted && _cameraPermissionGranted;
  
  void setLocationPermission(bool granted) {
    _locationPermissionGranted = granted;
    _updatePhase();
    notifyListeners();
  }
  
  void setCameraPermission(bool granted) {
    _cameraPermissionGranted = granted;
    _updatePhase();
    notifyListeners();
  }
  
  void moveToMapNavigation() {
    _currentPhase = AppPhase.mapNavigation;
    notifyListeners();
  }
  
  void moveToMLDetection() {
    _currentPhase = AppPhase.mlDetection;
    notifyListeners();
  }
  
  void moveToARIntervention() {
    _currentPhase = AppPhase.arIntervention;
    notifyListeners();
  }
  
  void completeARIntervention() {
    _arInterventionCompleted = true;
    _currentPhase = AppPhase.completed;
    notifyListeners();
  }
  
  void _updatePhase() {
    if (allPermissionsGranted && _currentPhase == AppPhase.permissionsCheck) {
      _currentPhase = AppPhase.mapNavigation;
    }
  }
  
  void reset() {
    _currentPhase = AppPhase.permissionsCheck;
    _locationPermissionGranted = false;
    _cameraPermissionGranted = false;
    _arInterventionCompleted = false;
    notifyListeners();
  }
}
