import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/ml_provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ml_overlay.dart';
import 'ar_intervention_screen.dart';

class CameraMLScreen extends StatefulWidget {
  const CameraMLScreen({super.key});

  @override
  State<CameraMLScreen> createState() => _CameraMLScreenState();
}

class _CameraMLScreenState extends State<CameraMLScreen> {
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    final mlProvider = context.read<MLProvider>();
    await mlProvider.initializeCamera();
    
    // Start ML processing after camera is initialized
    if (mlProvider.cameraController?.value.isInitialized == true) {
      await mlProvider.startMLProcessing();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('RECONOCIMIENTO ML'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<MLProvider>().stopMLProcessing();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<MLProvider>(
        builder: (context, mlProvider, _) {
          final controller = mlProvider.cameraController;
          
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Inicializando cámara...',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            );
          }
          
          return Stack(
            children: [
              // Camera preview
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(controller),
              ),
              
              // ML Overlay
              MLOverlay(
                detection: mlProvider.currentDetection,
                isProcessing: mlProvider.isProcessing,
              ),
              
              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.backgroundDark.withOpacity(0.0),
                        AppTheme.backgroundDark.withOpacity(0.9),
                        AppTheme.backgroundDark,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.secondaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mlProvider.hasValidDetection
                                    ? '¡Residuo detectado! Procede a AR'
                                    : 'Apunta la cámara a un residuo (botella, papel, etc.)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: mlProvider.hasValidDetection
                                          ? AppTheme.primaryGreen
                                          : AppTheme.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: mlProvider.hasValidDetection
                              ? () {
                                  mlProvider.stopMLProcessing();
                                  context
                                      .read<AppStateProvider>()
                                      .moveToARIntervention();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ARInterventionScreen(),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.view_in_ar),
                          label: const Text('INICIAR INTERVENCIÓN AR'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: mlProvider.hasValidDetection
                                ? AppTheme.primaryGreen
                                : AppTheme.textSecondary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
