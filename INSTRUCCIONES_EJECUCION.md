# Instrucciones de Ejecución - Operación Campus

## IMPORTANTE: Esta app NO funciona en Web

La aplicación **Operación Campus UIDE** utiliza características nativas que solo están disponibles en dispositivos móviles:

- **GPS/Geolocalización** - Requiere hardware GPS real
- **Cámara** - Para visión por computadora ML  
- **Google Maps nativo** - Plugins nativos de Android/iOS
- **Sensores AR** - ARCore (Android) / ARKit (iOS)

## Opción 1: Ejecutar en Dispositivo Android Físico

1. **Habilitar modo desarrollador** en tu teléfono Android:
   - Ve a Ajustes > Acerca del teléfono
   - Toca 7 veces en "Número de compilación"
   - Activa "Depuración USB"

2. **Conectar dispositivo**:
   ```bash
   flutter devices
   # Debe aparecer tu dispositivo Android
   ```

3. **Ejecutar**:
   ```bash
   flutter run
   # Selecciona tu dispositivo Android
   ```

## Opción 2: Emulador Android (con Google Play)

1. **Abrir Android Studio** > AVD Manager

2. **Crear un emulador** con:
   - Sistema: Android 11+ (API 30+)
   - **IMPORTANTE**: Imagen con "Google Play" (no "Google APIs")
   - GPU habilitada

3. **Iniciar emulador**

4. **Ejecutar**:
   ```bash
   flutter run
   ```

5. **Simular ubicación GPS** en el emulador:
   - Click en "..." (More) en el panel lateral
   - Location > Ingresar coordenadas:
     - Latitude: -3.9929
     - Longitude: -79.2047
   - Click "Send"

## Opción 3: iOS (Solo macOS)

```bash
flutter run -d ios
```

## No olvides: Google Maps API Key

Antes de ejecutar, edita:  
`android/app/src/main/AndroidManifest.xml`

Reemplaza `YOUR_API_KEY_HERE` con tu API key real de Google Maps.

## ¿Por qué no funciona en Chrome/Web?

Flutter Web no soporta nativamente:
- `geolocator` (GPS no disponible en web como en móvil)
- `camera` (limitaciones de WebRTC)
- `google_maps_flutter` (usa plugins nativos)
- ARCore/ARKit (solo móvil)

---

**TL;DR**: Ejecuta `flutter run` con un dispositivo Android conectado o emulador. ✅
