class MLDetection {
  final String label;
  final double confidence;
  final DateTime timestamp;
  
  MLDetection({
    required this.label,
    required this.confidence,
    required this.timestamp,
  });
  
  bool get isValid => confidence >= 0.8; // 80% threshold
  
  @override
  String toString() => '$label (${(confidence * 100).toStringAsFixed(1)}%)';
}

enum DetectionCategory {
  bottle,
  paper,
  plastic,
  metal,
  other,
}

extension DetectionCategoryExtension on DetectionCategory {
  String get displayName {
    switch (this) {
      case DetectionCategory.bottle:
        return 'Botella';
      case DetectionCategory.paper:
        return 'Papel';
      case DetectionCategory.plastic:
        return 'Plástico';
      case DetectionCategory.metal:
        return 'Metal';
      case DetectionCategory.other:
        return 'Residuo';
    }
  }
}
