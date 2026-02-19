---
sidebar_position: 1
---

# Optimización de Performance

Una buena performance es crítica para la experiencia del usuario. Flutter es rápido por naturaleza, pero hay optimizaciones que puedes hacer.

## FPS y Jank

### 60 FPS vs 120 FPS

- **60 FPS**: 16.6 ms por frame (estándar)
- **120 FPS**: 8.3 ms por frame (dispositivos high-end)
- **Jank**: Frame que tarda más de lo normal

```dart
// Medir duración de operación
final stopwatch = Stopwatch()..start();
miOperacion();
stopwatch.stop();
print('Tiempo: ${stopwatch.elapsedMilliseconds}ms');
```

## Problemas Comunes

### 1. Widget Rebuilds Innecesarios

```dart
// ❌ MAL - Reconstruye todo
class MiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MiComponentePesado(),
        OtroComponente(),
      ],
    );
  }
}

// ✅ BIEN - Separa en widgets más pequeños
class MiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ComponentePesadoConstante(),
        OtroComponente(),
      ],
    );
  }
}

class ComponentePesadoConstante extends StatelessWidget {
  const ComponentePesadoConstante();

  @override
  Widget build(BuildContext context) {
    return ExpensiveWidget();
  }
}
```

### 2. Lists Sin Optimization

```dart
// ❌ MAL - Reconstruye todos los items
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
)

// ✅ BIEN - Usa addAutomaticKeepAlives
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) {
    return ListItem(
      key: ValueKey(items[index].id),
      item: items[index],
    );
  },
)
```

### 3. Heavy Computations en Build

```dart
// ❌ MAL
class MiWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resultado = procesarListaGrande(items); // ¡Cada build!
    return Text(resultado);
  }
}

// ✅ BIEN
class MiWidget extends StatefulWidget {
  @override
  State<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> {
  late final resultado = procesarListaGrande(items); // Una sola vez

  @override
  Widget build(BuildContext context) {
    return Text(resultado);
  }
}
```

## Herramientas de Debugging

### DevTools Performance Tab

```bash
flutter pub global activate devtools
devtools
```

### Performance Layer

```dart
void main() {
  // Mostrar overlay de performance
  debugPrintBeginFrameBanner = true;
  debugPrintEndFrameBanner = true;
  runApp(MyApp());
}
```

## Optimizaciones Clave

| Problema | Solución | Impacto |
|----------|----------|--------|
| Rebuilds | Keys + const | Alto |
| Heavy builds | compute() | Alto |
| Large lists | ListView.builder | Muy Alto |
| Overdraw | RepaintBoundary | Medio |
| Images | Caching | Alto |

## Mediciones

```dart
class PerformanceMonitor {
  final Stopwatch _stopwatch = Stopwatch();

  void start() => _stopwatch.start();

  void stop(String label) {
    _stopwatch.stop();
    print('$label: ${_stopwatch.elapsedMilliseconds}ms');
    _stopwatch.reset();
  }
}
```
