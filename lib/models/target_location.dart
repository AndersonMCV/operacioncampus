class TargetLocation {
  final double latitude;
  final double longitude;
  final String name;
  final String description;
  
  const TargetLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.description = '',
  });
  
  // Default: Campus UIDE Loja - Zona de Laboratorios (coordenadas aproximadas)
  static const TargetLocation defaultTarget = TargetLocation(
    latitude: -3.9929,
    longitude: -79.2047,
    name: 'Laboratorios UIDE Loja',
    description: 'Zona de crisis - Foco de contaminación virtual',
  );
}
