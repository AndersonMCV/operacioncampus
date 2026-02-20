# Auditoría Técnica y Ética: Operación Campus

**Fecha:** 19 de Febrero, 2026
**Autor:** AndersonMCV - alddrinW- Auditor Técnico

---

## 1. Comparativa Técnica: `geolocator` vs `location`

### Introducción
En el ecosistema Flutter, `geolocator` y `location` son las librerías predominantes para servicios de geolocalización. Para una aplicación de despliegue continuo como "Operación Campus", la elección impacta directamente en la autonomía del dispositivo y la experiencia del usuario.

### Análisis Comparativo

| Característica | `geolocator` (Google/Baseflow) | `location` (Lyokone) |
| :--- | :--- | :--- |
| **Consumo de Batería (Estimado)** | **Bajo**. Utiliza flujos de eventos (`Stream`) optimizados que suspenden el receptor cuando no hay cambios significativos. | **Medio-Alto**. Históricamente depende más de *polling* activo si no se configura agresivamente el filtrado de distancia. |
| **Gestión en Segundo Plano** | Requiere integración con paquetes externos (como `flutter_background_geolocation`) para control total, pero ofrece primitivas sólidas para servicios en primer plano persistentes. | Soporte nativo integrado pero con mayor complejidad para mantener el servicio activo sin ser eliminado por el SO (Android Doze mode). |
| **Polling vs Eventos** | Basado en **Eventos**. El hardware notifica al software solo al cruzar umbrales (distancia/tiempo). | Híbrido. Permite configuración de intervalos, pero su implementación interna en algunos disp. antiguos tiende al polling. |
| **Precisión y API** | API más moderna y granular (`LocationAccuracy.bestForNavigation`). | API más simple, pero menos opciones de control fino sobre el hardware GNSS. |

### Justificación de Elección
Se recomienda **`geolocator`** para el despliegue a largo plazo en el campus.
*   **Eficiencia Energética:** Su arquitectura basada en flujos permite que la CPU del dispositivo entre en *sleep* entre actualizaciones de ubicación, ahorrando mAh críticos.
*   **Mantenimiento:** Al ser mantenido por Baseflow (y recomendado por Google), tiene actualizaciones más frecuentes frente a cambios en las políticas de permisos de Android 14/15 e iOS 17+.
*   **Interoperabilidad:** Se integra nativamente con otros paquetes del ecosistema oficial.

> **Cita (APA):**
> Baseflow. (2024). *Geolocator: A Flutter geolocation plugin which provides easy access to platform specific location services*. pub.dev. https://pub.dev/packages/geolocator

---

## 2. Refactorización y Gestión de Estados

### Problema Identificado
El código original utilizaba un `Consumer<LocationProvider>` en el nivel más alto del `build` del `HomeScreen`.
*   **Consecuencia:** Cada vez que el GPS reportaba una nueva posición (e.g., cada segundo), **toda la pantalla**, incluyendo el mapa de Google (`GoogleMap`), se reconstruía.
*   **Impacto:** Reconstruir el mapa es costoso en CPU y GPU, causando "jank" (tirones) y consumo excesivo de batería.

### Solución Implementada
Se eliminó el `Consumer` global y se aplicó un enfoque granular usando `Selectos` y `Consumer` locales.

#### Código Refactorizado (Ejemplo)

```dart
// ANTES (Ineficiente)
// body: Consumer<LocationProvider>( builder: (ctx, provider, _) { return GoogleMap(...); } )

// DESPUÉS (Optimizado)
// El GoogleMap está fuera de cualquier Consumer, por lo que NO se reconstruye con cambios de GPS.
// Solo los widgets que cambian (texto de batería, radar) escuchan cambios.

Selector<LocationProvider, int>(
  selector: (_, provider) => provider.gpsRequestCount,
  builder: (context, count, _) {
    return Text('Peticiones GPS: $count'); // Solo esto se repinta
  },
),
```

### Beneficios
*   **Prevención de Memory Leaks:** Al no recrear el `GoogleMapController` constantemente, evitamos fugas de memoria nativa en la capa de Android/iOS.
*   **FPS Estables:** La interfaz se mantiene fluida a 60fps incluso con actualizaciones de ubicación de alta frecuencia.

---

## 3. Estrategia de Carga de Recursos (Lazy Loading)

### Evaluación de Recursos
*   **Modelo 3D Típico (.glb de alta calidad):** ~50 MB.
*   **Texturas Descomprimidas en VRAM:** ~200 MB.

### Lógica Implementada
Se creó el servicio `AssetLoaderService`. La aplicación ya no carga los modelos al iniciar.
1.  **Monitoreo:** La app monitorea la ubicación con bajo consumo.
2.  **Disparador:** Si `distancia_al_objetivo < 50 metros`.
3.  **Acción:** Se inicia la descarga/carga en memoria del recurso.

### Cálculo de Ahorro
*   **Escenario:** Un estudiante abre la app en su casa (lejos del campus).
*   **Ahorro de Datos:** 50 MB (no se descarga el modelo).
*   **Ahorro de RAM:** 200 MB liberados para otras apps del sistema.
*   **Dispositivos Gama Media:** Crucial para evitar que el SO cierre la app por "Out of Memory" (OOM) antes de llegar al sitio.

---

## 4. Postura Ética y Pensamiento Crítico

### Integración de IA y Sostenibilidad
El desarrollo de "software verde" no es solo una optimización técnica, es un imperativo ético. Una aplicación que desperdicia batería contribuye innecesariamente a la huella de carbono global, dado que la energía eléctrica a menudo proviene de fuentes no renovables. Como desarrolladores, somos responsables de los "ciclos de CPU" que nuestras creaciones consumen en millones de dispositivos.

### Sesgo en Modelos de IA (TensorFlow Lite)
Para verificar que el modelo de clasificación de residuos en Loja no esté sesgado:
1.  **Auditoría de Dataset:** No usar datasets genéricos de "basura" de EE.UU. o Europa (donde los envases son diferentes). Se debe recolectar y etiquetar un dataset local con imágenes de productos ecuatorianos reales en condiciones de luz y suciedad locales.
2.  **Matriz de Confusión por Clase:** Evaluar no solo la precisión global, sino el rendimiento por clase. Si el modelo falla desproporcionadamente en identificar marcas locales vs internacionales, existe un sesgo.

### Evitando Soluciones de "Fuerza Bruta"
Para asegurar que el código sugerido por una IA no degrade la batería:
*   **No confiar ciegamente:** La IA tiende a sugerir la solución más corta, que a menudo es la menos eficiente (e.g., *polling* infinito en lugar de *streams*).
*   **Profiling Obligatorio:** Ningún código generado por IA debe ir a producción sin pasar por el "Flutter Performance Overlay" y el perfilador de memoria.
*   **Principio de Mínimo Privilegio (Recursos):** Si la IA sugiere usar GPS de alta precisión todo el tiempo, el desarrollador debe corregir a "precisión media" o "solo al usar la app", aplicando el criterio humano de costo-beneficio.
