---
sidebar_position: 2
---

# Profiling en Flutter

El profiling es el arte de medir y analizar la performance de tu aplicación.

## Tipos de Profiling

### CPU Profiling

Mide qué funciones consumen más tiempo de CPU:

```dart
// En main.dart
import 'dart:developer' as developer;

void main() {
  // Iniciar grabación
  developer.Timeline.startSync('app_startup');
  
  runApp(MyApp());
  
  // Finalizar grabación
  developer.Timeline.finishSync();
}
```

### Memory Profiling

Identifica leaks de memoria y uso excesivo:

```dart
import 'dart:developer' as developer;

void checkMemory() {
  // En DevTools → Memory tab
  developer.Service.invoke('_signalServiceExtensionResponse',
    ['ext.dart.io.httpEnableTimelineLogging', 'true']
  );
}
```

## DevTools Profiler

### 1. Abrir DevTools

```bash
flutter pub global activate devtools
devtools
# Accede a http://localhost:9100
```

### 2. Tabs Importantes

- **Performance**: FPS, jank detection
- **Memory**: Heap snapshots, memory leaks
- **CPU Profiler**: Tiempo por función
- **Network**: Requests HTTP

## Frames Analysis

```dart
// Habilitar frame timing en debug
flutter run --profile

// Ver frames con problemas
// En DevTools → Performance → Frame Analysis
```

## Custom Timeline Events

```dart
import 'dart:developer' as developer;

Future<void> procesarDatos() async {
  developer.Timeline.startSync('procesamiento_inicio');
  
  try {
    await Future.delayed(Duration(seconds: 2));
    print('Procesamiento completado');
  } finally {
    developer.Timeline.finishSync();
  }
}
```

## Métricas Clave

| Métrica | Bueno | Aceptable | Malo |
|---------|-------|-----------|------|
| FPS | 60 | 50-60 | ‹50 |
| Memory | ‹50MB | 50-100MB | ›100MB |
| Startup | ‹1s | 1-2s | ›2s |
| Frame Budget | ‹16ms | 16-20ms | ›20ms |

## Memory Leaks Detection

```dart
class MiWidget extends StatefulWidget {
  @override
  State<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    // ⚠️ IMPORTANTE: Guardar referencia
    _subscription = miStream.listen((data) {
      setState(() {
        // Actualizar estado
      });
    });
  }

  @override
  void dispose() {
    // ✅ Limpiar subscription
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Optimización Basada en Profiling

### Ejemplo: Optimizar ListView

```dart
// Antes: Profiler muestra alto CPU usage
class ItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(
        1000,
        (index) => Text(generateExpensiveString(index)),
      ),
    );
  }
}

// Después: Usa ListView.builder
class ItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return Text(generateExpensiveString(index));
      },
    );
  }
}
```

## Profiling en Producción

```dart
// Usar Firebase Crashlytics para performance monitoring
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void recordOperation(String name, Future Function() operation) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    await operation();
  } finally {
    stopwatch.stop();
    await FirebaseCrashlytics.instance.recordFlutterError(
      FlutterErrorDetails(
        exception: 'Performance: $name took ${stopwatch.elapsedMilliseconds}ms',
      ),
    );
  }
}
```

## Herramientas Útiles

- **DevTools**: Herramienta oficial
- **Perfetto**: UI traces avanzada
- **Skia**: Para analizar rendering
- **Observatory**: Para problemas de memoria
