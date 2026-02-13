import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/uv_data_panel.dart';

class ARInterventionScreen extends StatefulWidget {
  const ARInterventionScreen({super.key});

  @override
  State<ARInterventionScreen> createState() => _ARInterventionScreenState();
}

class _ARInterventionScreenState extends State<ARInterventionScreen>
    with TickerProviderStateMixin {
  bool _isARInitialized = false;
  bool _objectAnchored = false;
  bool _interventionCompleted = false;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _initializeAR();
  }
  
  Future<void> _initializeAR() async {
    // Simulate AR initialization
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isARInitialized = true;
    });
    
    // Simulate plane detection and object anchoring
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _objectAnchored = true;
    });
  }
  
  void _onObjectTapped() {
    setState(() {
      _interventionCompleted = true;
    });
    
    context.read<AppStateProvider>().completeARIntervention();
    
    // Show success for a moment then allow navigation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showCompletionDialog();
      }
    });
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppTheme.primaryGreen,
            width: 2,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.primaryGreen),
            SizedBox(width: 12),
            Text(
              '¡Misión Cumplida!',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ],
        ),
        content: const Text(
          'Has completado exitosamente la Operación Campus. El foco de contaminación ha sido eliminado.',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('FINALIZAR'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('INTERVENCIÓN AR'),
        automaticallyImplyLeading: !_interventionCompleted,
      ),
      body: Stack(
        children: [
          // AR View simulation (placeholder - real implementation would use arcore_flutter_plugin)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppTheme.backgroundDark,
                  AppTheme.backgroundDark.withOpacity(0.8),
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: _buildARContent(),
            ),
          ),
          
          // Instructions overlay
          if (!_interventionCompleted)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withOpacity(0.9),
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
                        _objectAnchored
                            ? 'Toca el objeto 3D para completar la limpieza'
                            : _isARInitialized
                                ? 'Detectando plano para anclar objeto...'
                                : 'Inicializando AR...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // UV Data Panel
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: UVDataPanel(showSuccess: _interventionCompleted),
          ),
        ],
      ),
    );
  }
  
  Widget _buildARContent() {
    if (!_isARInitialized) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
            strokeWidth: 3,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: const Duration(seconds: 2)),
          const SizedBox(height: 20),
          const Text(
            'Inicializando ARCore...',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    
    if (!_objectAnchored) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanning plane indicator
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.secondaryBlue.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scaleXY(
                      duration: const Duration(seconds: 2),
                      begin: 0.8,
                      end: 1.2,
                    )
                    .fade(begin: 0.8, end: 0.0),
                const Icon(
                  Icons.grid_on,
                  size: 64,
                  color: AppTheme.secondaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Buscando superficie...',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    
    // 3D Object simulation (interactive)
    return GestureDetector(
      onTap: _interventionCompleted ? null : _onObjectTapped,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _interventionCompleted
                ? 1.0
                : 1.0 + (_pulseController.value * 0.1),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _interventionCompleted
                      ? [
                          AppTheme.primaryGreen,
                          AppTheme.primaryGreen.withOpacity(0.6),
                        ]
                      : [
                          AppTheme.secondaryBlue,
                          AppTheme.secondaryBlue.withOpacity(0.6),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_interventionCompleted
                            ? AppTheme.primaryGreen
                            : AppTheme.secondaryBlue)
                        .withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                _interventionCompleted ? Icons.check : Icons.cleaning_services,
                size: 80,
                color: AppTheme.backgroundDark,
              ),
            ),
          );
        },
      )
          .animate(target: _interventionCompleted ? 1 : 0)
          .rotate(
            duration: const Duration(milliseconds: 500),
            end: 1,
          )
          .scaleXY(
            duration: const Duration(milliseconds: 500),
            begin: 1.0,
            end: 1.5,
          ),
    );
  }
}
