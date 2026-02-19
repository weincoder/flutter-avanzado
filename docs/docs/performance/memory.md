---
sidebar_position: 3
---

# Memory Management

La gestión eficiente de memoria es crucial para aplicaciones móviles.

## Conceptos Básicos

### Heap vs Stack

- **Stack**: Variables locales, rápido, automático
- **Heap**: Objetos, controlado por GC, más lento

### Garbage Collection

Dart maneja la memoria automáticamente, pero puedes optimizar:

```dart
class MiClase {
  final List<int> datos = [];

  // ❌ Crecimiento no controlado
  void agregarDatos() {
    for (int i = 0; i < 1000000; i++) {
      datos.add(i); // ¡Crece indefinidamente!
    }
  }

  // ✅ Límite de tamaño
  void agregarDatosSeguro() {
    const maxSize = 10000;
    if (datos.length >= maxSize) {
      datos.clear();
    }
    for (int i = 0; i < 100; i++) {
      datos.add(i);
    }
  }
}
```

## Detección de Memory Leaks

### Patrón Problema

```dart
class MiProvider extends ChangeNotifier {
  static final _instance = MiProvider._();
  
  factory MiProvider() => _instance;
  MiProvider._();

  // ❌ Referencias que nunca se limpian
  final List<StreamSubscription> _subscriptions = [];

  void subscribe(Stream stream) {
    _subscriptions.add(stream.listen((_) {}));
    // Nunca se cancela
  }
}
```

### Solución

```dart
class MiProvider extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];

  void subscribe(Stream stream) {
    _subscriptions.add(stream.listen((_) {
      notifyListeners();
    }));
  }

  @override
  void dispose() {
    // ✅ Cancelar todas las subscripciones
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
```

## Optimización de Images

Las imágenes consumen mucha memoria:

```dart
// ❌ MAL - Carga full resolution
Image.network('https://example.com/large-image.png')

// ✅ BIEN - Especificar tamaño
Image.network(
  'https://example.com/large-image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// ✅ MEJOR - Cache y lazy loading
class CachedImage extends StatelessWidget {
  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      memCacheHeight: 200,
      memCacheWidth: 200,
    );
  }
}
```

## Caching Estrategico

```dart
class CacheManager {
  static final _cache = <String, dynamic>{};
  static const maxSize = 50; // Items máximos

  static void set(String key, dynamic value) {
    if (_cache.length >= maxSize) {
      // Limpiar items antiguos
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  static dynamic get(String key) => _cache[key];

  static void clear() => _cache.clear();

  static int get size => _cache.length;
}
```

## ListView Memory Efficiency

```dart
// ❌ MAL - Mantiene todos los items en memoria
ListView(
  children: List.generate(1000, (i) => HeavyWidget(index: i)),
)

// ✅ BIEN - Carga items bajo demanda
ListView.builder(
  cacheExtent: 500, // Pixels de buffer
  itemCount: 1000,
  itemBuilder: (context, index) => HeavyWidget(index: index),
)
```

## Monitoreo de Memoria

```dart
import 'dart:async';
import 'dart:developer' as developer;

class MemoryMonitor {
  static Future<void> startMonitoring() async {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      final info = await developer.Service.getVM();
      // Analizar info de memoria
      print('Memory: ${info.toString()}');
    });
  }
}
```

## Ciclo de Vida de Widgets

```dart
class MiWidget extends StatefulWidget {
  @override
  State<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> with WidgetsBindingObserver {
  late StreamSubscription _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Inicializar recursos
    _subscription = stream.listen((_) {});
    _timer = Timer.periodic(Duration(seconds: 1), (_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause: limpiar recursos
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // Resume: reactivar
      _timer = Timer.periodic(Duration(seconds: 1), (_) {});
    }
  }

  @override
  void dispose() {
    // Limpiar TODO
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Checklist de Memory

- ✅ Cancelar todas las subscripciones en `dispose()`
- ✅ Cancelar timers en `dispose()`
- ✅ Limpiar listeners en `dispose()`
- ✅ Descargar images grandes
- ✅ Usar `ListView.builder` para listas largas
- ✅ Establecer límites de caché
- ✅ Evitar referencias circulares
- ✅ Monitorear en DevTools

## Tools para Debugging

```bash
# Generar heap snapshot
flutter run --profile

# En DevTools → Memory tab → Capture heap snapshot
```
