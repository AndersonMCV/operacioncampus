import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class UVDataPanel extends StatelessWidget {
  final bool showSuccess;
  
  const UVDataPanel({
    super.key,
    this.showSuccess = false,
  });
  
  // Simulate UV data (Solmáforo reference)
  double get _currentUVIndex => 8.5 + Random().nextDouble() * 3;
  
  String get _uvRiskLevel {
    final uv = _currentUVIndex;
    if (uv < 3) return 'BAJO';
    if (uv < 6) return 'MODERADO';
    if (uv < 8) return 'ALTO';
    if (uv < 11) return 'MUY ALTO';
    return 'EXTREMO';
  }
  
  Color get _uvColor {
    final uv = _currentUVIndex;
    if (uv < 3) return Colors.green;
    if (uv < 6) return Colors.yellow;
    if (uv < 8) return Colors.orange;
    if (uv < 11) return Colors.red;
    return Colors.purple;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceDark,
            AppTheme.surfaceDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: showSuccess
              ? AppTheme.primaryGreen
              : AppTheme.secondaryBlue,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (showSuccess ? AppTheme.primaryGreen : AppTheme.secondaryBlue)
                .withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                showSuccess ? Icons.check_circle : Icons.wb_sunny,
                color: showSuccess ? AppTheme.primaryGreen : _uvColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  showSuccess
                      ? '¡INTERVENCIÓN COMPLETADA!'
                      : 'Datos Ambientales - Solmáforo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: showSuccess
                            ? AppTheme.primaryGreen
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (showSuccess) ...[
            // Success message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.eco,
                    color: AppTheme.primaryGreen,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Foco de contaminación eliminado',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El ambiente digital ha sido purificado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .scale(delay: const Duration(milliseconds: 200)),
          ],
          
          const SizedBox(height: 16),
          
          // UV Index display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Índice UV Actual',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentUVIndex.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: _uvColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _uvColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _uvColor),
                          ),
                          child: Text(
                            _uvRiskLevel,
                            style: TextStyle(
                              color: _uvColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Simulated UV trend graph
          _buildUVTrendGraph(),
          
          const SizedBox(height: 16),
          
          // Additional data
          _buildDataRow(
            context,
            icon: Icons.location_on,
            label: 'Ubicación',
            value: 'Campus UIDE Loja',
          ),
          const SizedBox(height: 8),
          _buildDataRow(
            context,
            icon: Icons.access_time,
            label: 'Timestamp',
            value: _getCurrentTime(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUVTrendGraph() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (index) {
          final height = 20 + Random().nextDouble() * 40;
          final isHighlight = index == 11; // Current value
          return Container(
            width: 8,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isHighlight
                    ? [_uvColor, _uvColor.withOpacity(0.6)]
                    : [
                        AppTheme.secondaryBlue.withOpacity(0.5),
                        AppTheme.secondaryBlue.withOpacity(0.2),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildDataRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.secondaryBlue,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
  
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}
