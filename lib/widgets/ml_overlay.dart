import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ml_detection.dart';
import '../theme/app_theme.dart';

class MLOverlay extends StatelessWidget {
  final MLDetection? detection;
  final bool isProcessing;
  
  const MLOverlay({
    super.key,
    required this.detection,
    required this.isProcessing,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scanning grid overlay
        if (isProcessing && detection == null)
          _buildScanningGrid(),
        
        // Detection result
        if (detection != null)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: _buildDetectionCard(context, detection!),
          ),
        
        // Corner markers (viewfinder style)
        _buildCornerMarkers(),
        
        // Processing indicator
        if (isProcessing)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Procesando ML...',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildScanningGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: _ScanningGridPainter(),
    );
  }
  
  Widget _buildDetectionCard(BuildContext context, MLDetection detection) {
    final isValid = detection.isValid;
    final confidence = (detection.confidence * 100).toStringAsFixed(1);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid
              ? AppTheme.primaryGreen
              : AppTheme.warningYellow,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isValid ? AppTheme.primaryGreen : AppTheme.warningYellow)
                .withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isValid
                    ? AppTheme.primaryGreen
                    : AppTheme.warningYellow,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.label.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isValid
                                ? AppTheme.primaryGreen
                                : AppTheme.warningYellow,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confianza: $confidence%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: detection.confidence,
              minHeight: 8,
              backgroundColor: AppTheme.backgroundDark,
              valueColor: AlwaysStoppedAnimation(
                isValid ? AppTheme.primaryGreen : AppTheme.warningYellow,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (!isValid)
            Text(
              'Se requiere ≥80% de confianza',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          
          if (isValid)
            Text(
              '✓ Detección válida - Listo para AR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildCornerMarkers() {
    return Stack(
      children: [
        // Top-left
        Positioned(
          top: 80,
          left: 40,
          child: _CornerMarker(isTopLeft: true),
        ),
        // Top-right
        Positioned(
          top: 80,
          right: 40,
          child: _CornerMarker(isTopRight: true),
        ),
        // Bottom-left
        Positioned(
          bottom: 200,
          left: 40,
          child: _CornerMarker(isBottomLeft: true),
        ),
        // Bottom-right
        Positioned(
          bottom: 200,
          right: 40,
          child: _CornerMarker(isBottomRight: true),
        ),
      ],
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;
  
  const _CornerMarker({
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _CornerMarkerPainter(
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: const Duration(milliseconds: 800))
        .then()
        .fadeOut(duration: const Duration(milliseconds: 800));
  }
}

class _CornerMarkerPainter extends CustomPainter {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;
  
  _CornerMarkerPainter({
    required this.isTopLeft,
    required this.isTopRight,
    required this.isBottomLeft,
    required this.isBottomRight,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    if (isTopLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTopRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isBottomLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    } else if (isBottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanningGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.2)
      ..strokeWidth = 1;
    
    // Draw grid lines
    const spacing = 40.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
