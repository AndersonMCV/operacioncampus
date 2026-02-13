import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class PermissionErrorScreen extends StatelessWidget {
  final Map<Permission, PermissionStatus> permissionStatuses;
  final VoidCallback onRetry;
  
  const PermissionErrorScreen({
    super.key,
    required this.permissionStatuses,
    required this.onRetry,
  });
  
  bool get hasLocationPermission =>
      permissionStatuses[Permission.location]?.isGranted == true;
  
  bool get hasCameraPermission =>
      permissionStatuses[Permission.camera]?.isGranted == true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.errorPink.withOpacity(0.2),
                    border: Border.all(
                      color: AppTheme.errorPink,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 60,
                    color: AppTheme.errorPink,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Permisos Requeridos',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Operación Campus necesita ciertos permisos para funcionar correctamente.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Location permission card
                _buildPermissionCard(
                  context,
                  icon: Icons.location_on,
                  title: 'Ubicación',
                  description:
                      'Necesitamos tu ubicación para localizarte en el campus y calcular la distancia al objetivo.',
                  isGranted: hasLocationPermission,
                ),
                
                const SizedBox(height: 16),
                
                // Camera permission card
                _buildPermissionCard(
                  context,
                  icon: Icons.camera_alt,
                  title: 'Cámara',
                  description:
                      'La cámara es necesaria para el reconocimiento de objetos mediante Machine Learning y la Realidad Aumentada.',
                  isGranted: hasCameraPermission,
                ),
                
                const Spacer(),
                
                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Intentar de Nuevo'),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openAppSettings(),
                        icon: const Icon(Icons.settings),
                        label: const Text('Abrir Configuración'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(
                            color: AppTheme.primaryGreen,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppTheme.primaryGreen.withOpacity(0.5)
              : AppTheme.errorPink.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGranted
                  ? AppTheme.primaryGreen.withOpacity(0.2)
                  : AppTheme.errorPink.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: isGranted ? AppTheme.primaryGreen : AppTheme.errorPink,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Icon(
                      isGranted ? Icons.check_circle : Icons.cancel,
                      color: isGranted
                          ? AppTheme.primaryGreen
                          : AppTheme.errorPink,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
