import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ProximityRadar extends StatelessWidget {
  final double? distanceToTarget;
  final bool isAccuracyGood;
  
  const ProximityRadar({
    super.key,
    required this.distanceToTarget,
    required this.isAccuracyGood,
  });
  
  Color _getColorForDistance(double? distance) {
    if (distance == null) return AppTheme.textSecondary;
    if (distance > 100) return AppTheme.secondaryBlue;
    if (distance > 50) return AppTheme.warningYellow;
    if (distance > 10) return AppTheme.primaryGreen;
    return AppTheme.primaryGreen;
  }
  
  Duration _getPulseDuration(double? distance) {
    if (distance == null) return const Duration(seconds: 2);
    if (distance > 100) return const Duration(milliseconds: 2000);
    if (distance > 50) return const Duration(milliseconds: 1500);
    if (distance > 10) return const Duration(milliseconds: 1000);
    return const Duration(milliseconds: 500);
  }
  
  String _getStatusText(double? distance) {
    if (distance == null) return 'Buscando señal GPS...';
    if (distance > 100) return 'Lejos del objetivo';
    if (distance > 50) return 'Acercándose...';
    if (distance > 10) return '¡Muy cerca!';
    return '¡OBJETIVO ALCANZADO!';
  }
  
  @override
  Widget build(BuildContext context) {
    final color = _getColorForDistance(distanceToTarget);
    final pulseDuration = _getPulseDuration(distanceToTarget);
    final statusText = _getStatusText(distanceToTarget);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Radar circles
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse circles
              ...List.generate(3, (index) {
                return Container(
                  width: 200 - (index * 30),
                  height: 200 - (index * 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .fade(
                      duration: pulseDuration,
                      begin: 0.8,
                      end: 0.0,
                      delay: Duration(milliseconds: index * 200),
                    )
                    .scale(
                      duration: pulseDuration,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      delay: Duration(milliseconds: index * 200),
                    );
              }),
              
              // Center indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isAccuracyGood ? Icons.gps_fixed : Icons.gps_not_fixed,
                  color: AppTheme.backgroundDark,
                  size: 32,
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white.withOpacity(0.3),
                  ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Status text
        Text(
          statusText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .fadeIn(duration: const Duration(milliseconds: 500))
            .then()
            .shimmer(duration: const Duration(seconds: 2)),
        
        if (distanceToTarget != null) ...[
          const SizedBox(height: 8),
          Text(
            '${distanceToTarget!.toStringAsFixed(1)} metros',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
        
        if (isAccuracyGood) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Precisión GPS óptima',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
