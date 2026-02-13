import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check all required permissions
  static Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    return {
      Permission.location: await Permission.location.status,
      Permission.camera: await Permission.camera.status,
      Permission.locationWhenInUse: await Permission.locationWhenInUse.status,
    };
  }
  
  // Request location permission
  static Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }
  
  // Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }
  
  // Request all permissions at once
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.location,
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();
  }
  
  // Check if all permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final locationStatus = await Permission.location.status;
    final cameraStatus = await Permission.camera.status;
    
    return locationStatus.isGranted && cameraStatus.isGranted;
  }
  
  // Open app settings
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
  
  // Get permission status as readable string
  static String getStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Concedido';
      case PermissionStatus.denied:
        return 'Denegado';
      case PermissionStatus.permanentlyDenied:
        return 'Denegado permanentemente';
      case PermissionStatus.restricted:
        return 'Restringido';
      case PermissionStatus.limited:
        return 'Limitado';
      default:
        return 'Desconocido';
    }
  }
}
