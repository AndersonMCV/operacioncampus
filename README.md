# Operación Campus UIDE

**Aplicación Flutter para geolocalización, Machine Learning y Realidad Aumentada**

## Video Demostrativo

[**VER VIDEO DEMOSTRATIVO (YouTube)**](https://youtube.com/...)  
*Duración: < 2 minutos. Case study mostrando permisos, geolocalización, ML y AR.*

## Informe Técnico

[**Leer INFORME_TECNICO.md**](INFORME_TECNICO.md) con la justificación de arquitectura y manejo de batería.

## Auditoría de Eficiencia y Arquitectura (Actividad 2.15)
Este proyecto ha sido auditado y optimizado siguiendo estándares de "Software Verde" y alto rendimiento.

**📄 Ver Informe Completo:** [AUDIT_REPORT.md](AUDIT_REPORT.md)

### 🚀 Mejoras Implementadas
1.  **Optimización de Renderizado:** Refactorización de `HomeScreen` para eliminar reconstrucciones costosas del mapa durante actualizaciones de GPS.
2.  **Lazy Loading Inteligente:** Los modelos 3D pesados solo se cargan cuando el usuario está a menos de **50 metros** del objetivo, ahorrando ~50MB de datos y ~200MB de RAM.
3.  **Gestión de Estado:** Uso granular de `Provider` y `Selector` para minimizar el impacto en el hilo UI.

---

## Descripción

Aplicación desarrollada para el campus Loja de la UIDE que combina:
- **Geolocalización de alta precisión** con GPS adaptativo
- **Machine Learning (Visión Artificial)** para clasificación de objetos
- **Realidad Aumentada** para intervención digital
- **Diseño Cyber-Ecology** con tema oscuro optimizado para exteriores

## Funcionalidades Implementadas

### 1. Gestión de Permisos
- Sistema personalizado de solicitud de permisos (ubicación y cámara)
- Vista de error custom sin diálogos estándar del sistema

### 2. Navegación Geolocalizada
- Mapa de Google Maps con estilo oscuro customizado
- **Indicador de Proximidad Dinámico**: Radar pulsante que cambia de color y velocidad según distancia
- Geofencing con radio de precisión de 5 metros
- **Muestreo GPS Adaptativo** para eficiencia energética

### 3. Reconocimiento ML
- Procesamiento en tiempo real con cámara
- Umbral de confianza del 80% para validar detección
- Placeholder para integración TensorFlow Lite

### 4. Intervención AR
- Simulación de ARCore/ARKit
- Objeto 3D interactivo anclado
- Panel de datos UV simulados (inspirado en Solmáforo)

## Instalación

> [!IMPORTANT]
> **Esta aplicación REQUIERE un dispositivo móvil Android o iOS**. No funciona en web debido a que usa GPS nativo, cámara y sensores AR.

```bash
flutter pub get
```

### Configurar Google Maps API Key

**Android**: Edita `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### Ejecutar

1. Conecta tu dispositivo Android (con depuración USB activa)
2. Ejecuta:
```bash
flutter run
```

## Paleta Cyber-Ecology

- Primary Green: `#00FF94`
- Secondary Blue: `#00D4FF`
- Background Dark: `#0A0E1A`
- Surface Dark: `#1A1F35`

## Arquitectura

- **State Management**: Provider (Ver justificación en [INFORME_TECNICO.md](INFORME_TECNICO.md))
- **Providers**: `AppStateProvider`, `LocationProvider`, `MLProvider`
- **Screens**: Permission Error, Home (Maps), Camera ML, AR Intervention
- **Widgets**: Proximity Radar, ML Overlay, UV Data Panel

## Próximas Mejoras

1. Integración TensorFlow Lite real con modelo `.tflite`
2. AR real con ARCore/ARKit
3. Caché de mapas offline

## Compatibilidad

- Android: API 21+
- iOS: iOS 11.0+
- Requisitos: GPS, Cámara

---

**Proyecto académico UIDE Loja**
