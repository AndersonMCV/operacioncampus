import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/location_provider.dart';
import 'providers/ml_provider.dart';
import 'services/permission_service.dart';
import 'screens/permission_error_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OperacionCampusApp());
}

class OperacionCampusApp extends StatelessWidget {
  const OperacionCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MLProvider()),
      ],
      child: MaterialApp(
        title: 'Operación Campus UIDE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate();
  }
  
  Future<void> _checkPermissionsAndNavigate() async {
    // Show splash for a moment
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check permissions
    final permissionStatuses = await PermissionService.checkAllPermissions();
    final locationGranted = permissionStatuses[Permission.location]?.isGranted ?? false;
    final cameraGranted = permissionStatuses[Permission.camera]?.isGranted ?? false;
    
    if (!mounted) return;
    
    if (!locationGranted || !cameraGranted) {
      // Request permissions
      final requestResult = await PermissionService.requestAllPermissions();
      
      final locationNowGranted = requestResult[Permission.location]?.isGranted ?? false;
      final cameraNowGranted = requestResult[Permission.camera]?.isGranted ?? false;
      
      if (!mounted) return;
      
      if (!locationNowGranted || !cameraNowGranted) {
        // Show permission error screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PermissionErrorScreen(
              permissionStatuses: requestResult,
              onRetry: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }
      
      // Update app state
      if (mounted) {
        context.read<AppStateProvider>().setLocationPermission(locationNowGranted);
        context.read<AppStateProvider>().setCameraPermission(cameraNowGranted);
      }
    } else {
      // All permissions granted
      if (mounted) {
        context.read<AppStateProvider>().setLocationPermission(true);
        context.read<AppStateProvider>().setCameraPermission(true);
      }
    }
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  size: 80,
                  color: AppTheme.backgroundDark,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                'OPERACIÓN CAMPUS',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'UIDE Loja',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryBlue,
                      letterSpacing: 1,
                    ),
              ),
              
              const SizedBox(height: 60),
              
              // Loading indicator
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                  strokeWidth: 3,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Inicializando sistemas...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
