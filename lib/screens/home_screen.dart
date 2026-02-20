import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/location_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/proximity_radar.dart';
import '../theme/app_theme.dart';
import 'camera_ml_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    // Start location updates when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().startLocationUpdates();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Removed top-level Consumer<LocationProvider>
    // This prevents the entire Scaffold (and especially the GoogleMap) from 
    // rebuilding on every single location update (GPS tick).
    // Instead, we use specific Consumers/Selectors only for widgets that actually need to change.
    
    // Access target data once since it doesn't change frequently
    final target = context.read<LocationProvider>().target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPERACIÓN CAMPUS'),
        actions: [
          // GPS request counter (energy efficiency indicator)
          // OPTIMIZATION: Only this widget rebuilds when gpsRequestCount changes
          Selector<LocationProvider, int>(
            selector: (_, provider) => provider.gpsRequestCount,
            builder: (context, count, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.battery_charging_full,
                          size: 16,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps
          // OPTIMIZATION: This widget is now stable and won't rebuild on every GPS update
          // unless markers/circles explicitly need to change (handled internally by GoogleMap if we passed a Stream/Set)
          // But here we want to avoid recreating the GoogleMap widget itself.
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(target.latitude, target.longitude),
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Set dark map style
              controller.setMapStyle(_darkMapStyle);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              // Target marker
              Marker(
                markerId: const MarkerId('target'),
                position: LatLng(target.latitude, target.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(
                  title: target.name,
                  snippet: target.description,
                ),
              ),
            },
            circles: {
              // Accuracy circle around target
              Circle(
                circleId: const CircleId('target_area'),
                center: LatLng(target.latitude, target.longitude),
                radius: 5, // 5 meters activation radius
                fillColor: AppTheme.primaryGreen.withOpacity(0.2),
                strokeColor: AppTheme.primaryGreen,
                strokeWidth: 2,
              ),
            },
          ),
          
          // Bottom sheet with proximity radar and controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundDark.withOpacity(0.0),
                    AppTheme.backgroundDark,
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // OPTIMIZATION: Only the radar and distance/accuracy texts rebuild now
                    Consumer<LocationProvider>(
                      builder: (context, locationProvider, _) {
                        final distance = locationProvider.distanceToTarget;
                        final isAccurate = locationProvider.isAccuracyGoodEnough;
                        final currentPos = locationProvider.currentPosition;
                        
                        return Column(
                          children: [
                            ProximityRadar(
                              distanceToTarget: distance,
                              isAccuracyGood: isAccurate,
                            ),

                            const SizedBox(height: 24),
                            
                            // Mission info (static)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppTheme.warningYellow,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'OBJETIVO: ${target.name}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.warningYellow,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    target.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Activate camera button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isAccurate
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CameraMLScreen(),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.camera_alt),
                                label: Text(
                                  isAccurate
                                      ? 'ACTIVAR CÁMARA'
                                      : 'Acércate más (GPS < 5m)',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: isAccurate
                                      ? AppTheme.primaryGreen
                                      : AppTheme.textSecondary.withOpacity(0.3),
                                ),
                              ),
                            ),
                            
                            if (!isAccurate && distance != null && distance < 10) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Precisión actual: ${currentPos?.accuracy.toStringAsFixed(1) ?? "N/A"}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Dark map style for cyber-ecology theme
  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#1a1f35"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#b0b8cc"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#0a0e1a"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#00d4ff"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#2a2f45"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38405f"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1a1f35"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#00d4ff"}]
    }
  ]
  ''';
}
