---
sidebar_position: 3
---

# Isolates Avanzado — Evolucionando `intro_isolates`

Ya entendemos cómo funciona el proyecto `intro_isolates`: un isolate separado ejecuta un cómputo pesado y envía el resultado de vuelta. Pero la comunicación es **unidireccional** — el main isolate no puede enviar mensajes al worker.

En esta sección vamos a **evolucionar** el ejemplo con patrones avanzados que necesitarás en apps reales.

> 🚀 **Proyecto completo**: Todo el código de esta sección está implementado en el proyecto [`advanced_isolates`](https://github.com/weincoder/flutter-avanzado/tree/main/isolates/advanced_isolates). Cada patrón tiene su propia pantalla interactiva con el GIF del gato como indicador visual.

## 🗺 Hoja de ruta

| Patrón | ¿Qué resuelve? | Archivo |
|---|---|---|
| [Comunicación bidireccional](#-comunicación-bidireccional) | Enviar y recibir mensajes entre isolates | `lib/isolates/bidirectional_isolate.dart` |
| [Isolate de larga vida](#-isolate-de-larga-vida) | Reutilizar un isolate para múltiples tareas | `lib/isolates/persistent_worker.dart` |
| [Reportar progreso](#-reportar-progreso) | Enviar actualizaciones parciales a la UI | `lib/isolates/progress_isolate.dart` |
| [Pool de isolates](#-pool-de-isolates) | Ejecutar múltiples tareas en paralelo | `lib/isolates/isolate_pool.dart` |
| [Error handling](#-error-handling) | Manejar errores sin crashear la app | `lib/isolates/safe_isolate.dart` |
| [compute() simplificado](#-alternativa-compute) | La forma simple para operaciones únicas | `lib/isolates/compute_example.dart` |

## 🔄 Comunicación Bidireccional

En nuestro proyecto `intro_isolates`, la comunicación es así:

```
Main Isolate ──sendPort──► Worker Isolate
Main Isolate ◄──result──── Worker Isolate
```

Pero, ¿qué si necesitamos **enviar comandos** al isolate después de crearlo? Necesitamos un canal en ambas direcciones.

### Evolucionando `isolate_example.dart`

```dart
// 📂 lib/isolates/bidirectional_isolate.dart
import 'dart:isolate';

class BidirectionalIsolate {
  late SendPort _workerSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();
  Isolate? _isolate;

  bool get isRunning => _isolate != null;

  /// Inicia el isolate y establece comunicación bidireccional.
  ///
  /// El handshake funciona así:
  /// 1. Main crea un [ReceivePort] y pasa su [SendPort] al worker.
  /// 2. El worker crea su propio [ReceivePort] y envía su [SendPort] al main.
  /// 3. Ambos lados ahora tienen un [SendPort] del otro → bidireccional.
  Future<void> start() async {
    _isolate = await Isolate.spawn(
      _workerEntryPoint,
      _mainReceivePort.sendPort,
    );

    // El primer mensaje que recibimos es el SendPort del worker
    _workerSendPort = await _mainReceivePort.first as SendPort;
  }

  /// Envía un comando al worker y espera la respuesta.
  ///
  /// Cada llamada crea un [ReceivePort] temporal para la respuesta,
  /// lo que permite hacer múltiples llamadas concurrentes sin conflictos.
  Future<double> compute(int iterations) async {
    if (!isRunning) throw StateError('Isolate no iniciado. Llama a start()');

    final responsePort = ReceivePort();

    // Protocolo: [comando, datos, puerto de respuesta]
    _workerSendPort.send(['COMPUTE', iterations, responsePort.sendPort]);

    return await responsePort.first as double;
  }

  /// Libera recursos del isolate.
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _mainReceivePort.close();
  }

  /// Punto de entrada del isolate worker.
  ///
  /// Esta función DEBE ser top-level o static porque los isolates
  /// no pueden acceder a variables de instancia.
  static void _workerEntryPoint(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();

    // Paso 1 del handshake: enviar nuestro SendPort al main
    mainSendPort.send(workerReceivePort.sendPort);

    // Paso 2: escuchar comandos
    workerReceivePort.listen((message) {
      final command = message[0] as String;
      final iterations = message[1] as int;
      final responseSendPort = message[2] as SendPort;

      switch (command) {
        case 'COMPUTE':
          double result = 0.0;
          for (int i = 0; i < iterations; i++) {
            result += i;
          }
          responseSendPort.send(result);
          break;
        default:
          responseSendPort.send('Comando desconocido: $command');
      }
    });
  }
}
```

### Diferencias clave vs. la versión básica

| Concepto | `intro_isolates` | `BidirectionalIsolate` |
|---|---|---|
| Referencia al isolate | No se guarda | `Isolate? _isolate` |
| Estado | Sin control | `isRunning` getter |
| Validación | Ninguna | `StateError` si no está iniciado |
| Limpieza | Manual | `dispose()` con `Isolate.immediate` |
| Comandos | Un solo tipo | `switch` para múltiples comandos |
| Comunicación | Unidireccional | Bidireccional con handshake |

### Diagrama de comunicación bidireccional

```
┌──────────────────────┐          ┌──────────────────────┐
│     MAIN ISOLATE     │          │   WORKER ISOLATE     │
│                      │          │                      │
│ 1. Crear ReceivePort │          │                      │
│ 2. Isolate.spawn() ──┼─────────►│ 3. Crear ReceivePort │
│                      │          │                      │
│ 4. Recibir           │◄─────────┤ 5. Enviar SendPort   │
│    workerSendPort    │          │    al main           │
│                      │          │                      │
│ 6. Enviar comando ───┼─────────►│ 7. Recibir comando   │
│    ['COMPUTE', 1000] │          │    y procesar        │
│                      │          │                      │
│ 8. Recibir resultado │◄─────────┤ 9. Enviar resultado  │
└──────────────────────┘          └──────────────────────┘
```

### Demo interactiva: `bidirectional_page.dart`

En el proyecto `advanced_isolates`, cada patrón tiene su propia página. La demo bidireccional envía **2 tareas al mismo isolate** para demostrar la reutilización:

```dart
// 📂 lib/pages/bidirectional_page.dart (fragmento clave)
Future<void> _runDemo() async {
  setState(() {
    _isRunning = true;
    _status = '🚀 Iniciando isolate...';
  });

  try {
    // Paso 1: Iniciar el isolate (handshake bidireccional)
    await _isolate.start();

    // Paso 2: Enviar primera tarea
    final result1 = await _isolate.compute(500000000);
    setState(() {
      _result1 = result1.toStringAsExponential(4);
      _status = '🔄 Enviando tarea 2 al MISMO isolate...';
    });

    // Paso 3: Reutilizar el mismo isolate para otra tarea
    final result2 = await _isolate.compute(1000000000);
    setState(() {
      _result2 = result2.toStringAsExponential(4);
      _status = '✅ ¡Completado! Mismo isolate, 2 tareas';
    });
  } catch (e) {
    setState(() => _status = '❌ Error: $e');
  } finally {
    _isolate.dispose(); // Siempre limpiar
    setState(() => _isRunning = false);
  }
}
```

:::tip Ventaja clave
Con comunicación bidireccional, **reutilizas el mismo isolate** para múltiples tareas. Esto evita el overhead de crear y destruir isolates (~50-150ms cada vez).
:::

## 🔁 Isolate de Larga Vida

Nuestro `intro_isolates` original crea un isolate que muere después de enviar un resultado. En apps reales, querrás un isolate que **viva** mientras la app lo necesite.

### Patrón: Worker persistente

```dart
// 📂 lib/isolates/persistent_worker.dart
import 'dart:isolate';

class PersistentWorker {
  Isolate? _isolate;
  late SendPort _workerSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();

  bool get isRunning => _isolate != null;

  /// Crea el isolate y establece el canal de comunicación.
  Future<void> start() async {
    if (isRunning) return; // Evitar crear múltiples instancias

    _isolate = await Isolate.spawn(_workerLoop, _mainReceivePort.sendPort);
    _workerSendPort = await _mainReceivePort.first as SendPort;
  }

  /// Ejecuta una tarea en el worker persistente.
  ///
  /// Lanza [StateError] si el worker no ha sido iniciado.
  Future<double> execute(int iterations) async {
    if (!isRunning) throw StateError('Worker no iniciado. Llama a start()');

    final responsePort = ReceivePort();
    _workerSendPort.send([iterations, responsePort.sendPort]);
    return await responsePort.first as double;
  }

  /// Detiene el worker y libera todos los recursos.
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _mainReceivePort.close();
  }

  /// Loop principal del worker que escucha tareas indefinidamente.
  static void _workerLoop(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    port.listen((message) {
      final iterations = message[0] as int;
      final responseSendPort = message[1] as SendPort;

      double result = 0.0;
      for (int i = 0; i < iterations; i++) {
        result += i;
      }
      responseSendPort.send(result);
    });
  }
}
```

### Diferencia clave: `if (isRunning) return`

Observa esta línea en `start()`:

```dart
if (isRunning) return; // Evitar crear múltiples instancias
```

Esto protege contra un error común: llamar a `start()` más de una vez. Sin este guard, crearías múltiples isolates apuntando al mismo `_workerSendPort`, causando comportamiento impredecible.

### Ciclo de vida con StatefulWidget

En la demo real (`lib/pages/persistent_page.dart`), el worker se integra con el ciclo de vida del widget:

```dart
// 📂 lib/pages/persistent_page.dart (fragmento clave)
class _PersistentPageState extends State<PersistentPage> {
  final _worker = PersistentWorker();
  int _taskCount = 0;

  @override
  void initState() {
    super.initState();
    _initWorker(); // Iniciar el worker al crear el widget
  }

  Future<void> _initWorker() async {
    await _worker.start();
    if (mounted) {
      setState(() => _status = '✅ Worker listo — envía tareas!');
    }
  }

  @override
  void dispose() {
    _worker.dispose(); // ⚠️ Siempre limpiar recursos
    super.dispose();
  }

  Future<void> _runTask(int iterations) async {
    final result = await _worker.execute(iterations);
    _taskCount++;
    setState(() {
      _lastResult = result.toStringAsExponential(4);
      _status = '✅ Tarea #$_taskCount completada (mismo worker)';
    });
  }
}
```

La demo incluye **3 botones** con diferentes cargas de trabajo (100M, 500M, 1B iteraciones) para mostrar que el mismo worker las procesa todas secuencialmente sin recrearse.

:::caution Importante
Siempre llama a `dispose()` cuando ya no necesites el isolate. Los isolates que no se cierran **consumen memoria** indefinidamente.
:::

## 📊 Reportar Progreso

En nuestro `intro_isolates` original, no sabemos cuánto ha avanzado el cómputo pesado. El usuario solo ve el GIF animándose y espera. Mejoremos esto:

```dart
// 📂 lib/isolates/progress_isolate.dart
import 'dart:isolate';

class ProgressIsolate {
  /// Ejecuta el cómputo pesado reportando progreso como un [Stream].
  ///
  /// Valores entre 0.0 y 1.0 = progreso (0% a 100%).
  /// Último valor (mayor a 1.0) = resultado final del cómputo.
  static Stream<double> heavyProcessWithProgress(int totalIterations) {
    final receivePort = ReceivePort();

    Isolate.spawn(
      _worker,
      _WorkerConfig(
        sendPort: receivePort.sendPort,
        totalIterations: totalIterations,
      ),
    );

    // Convertir el ReceivePort a un Stream tipado
    return receivePort.cast<double>();
  }

  /// Función que corre en el isolate separado.
  static void _worker(_WorkerConfig config) {
    double result = 0.0;
    final reportEvery = config.totalIterations ~/ 100; // Reportar cada 1%

    for (int i = 0; i < config.totalIterations; i++) {
      result += i;

      // Reportar progreso cada 1%
      if (reportEvery > 0 && i % reportEvery == 0 && i > 0) {
        final progress = i / config.totalIterations;
        config.sendPort.send(progress); // Enviar 0.0 a 1.0
      }
    }

    // Enviar resultado final (siempre será > 1.0 para mil millones de iteraciones)
    config.sendPort.send(result);
  }
}

/// Configuración que se pasa al isolate worker.
///
/// Usamos una clase dedicada porque [Isolate.spawn] solo acepta
/// un argumento. Esta clase agrupa todos los datos necesarios.
class _WorkerConfig {
  final SendPort sendPort;
  final int totalIterations;

  _WorkerConfig({required this.sendPort, required this.totalIterations});
}
```

### Detalles importantes del guard

```dart
if (reportEvery > 0 && i % reportEvery == 0 && i > 0)
```

Este triple guard es clave:
1. **`reportEvery > 0`** — protege contra divisiones por cero si `totalIterations` es menor a 100.
2. **`i % reportEvery == 0`** — solo reporta en los intervalos del 1%.
3. **`i > 0`** — evita enviar progreso 0% inmediatamente al iniciar.

### Mostrando progreso en la UI

La demo real (`lib/pages/progress_page.dart`) usa un `StreamSubscription` y un `LinearProgressIndicator`:

```dart
// 📂 lib/pages/progress_page.dart (fragmento clave)
class _ProgressPageState extends State<ProgressPage> {
  double _progress = 0.0;
  StreamSubscription<double>? _subscription;

  void _runDemo() {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
    });

    final stream = ProgressIsolate.heavyProcessWithProgress(1000000000);

    _subscription = stream.listen(
      (value) {
        if (!mounted) return;

        if (value <= 1.0) {
          // Es un reporte de progreso
          setState(() {
            _progress = value;
            _status = '⏳ Progreso: ${(value * 100).toStringAsFixed(0)}%';
          });
        } else {
          // Es el resultado final
          setState(() {
            _progress = 1.0;
            _result = value.toStringAsExponential(4);
            _status = '✅ ¡Completado!';
            _isRunning = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancelar suscripción al cerrar
    super.dispose();
  }
}

// En el build():
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: LinearProgressIndicator(
    value: _progress,
    minHeight: 24,
  ),
),
```

```
🐱 GIF animándose        [████████░░░░░░░░░░░░] 42%
    ✅ UI fluida           El isolate reporta progreso
```

## 🏊 Pool de Isolates

Si necesitas ejecutar **múltiples tareas pesadas** simultáneamente, crear un isolate por tarea es costoso. Un pool reutiliza un número fijo de isolates:

```dart
// 📂 lib/isolates/isolate_pool.dart
import 'dart:io';
import 'dart:isolate';

class IsolatePool {
  final int size;
  final List<SendPort> _workers = [];
  final List<Isolate> _isolates = [];
  int _nextWorker = 0;

  /// Crea un pool con [size] workers.
  ///
  /// Por defecto usa `Platform.numberOfProcessors - 1` para dejar
  /// un core libre para el main isolate.
  IsolatePool({int? size})
    : size = size ?? (Platform.numberOfProcessors - 1).clamp(1, 8);

  bool get isInitialized => _workers.isNotEmpty;

  /// Inicializa todos los workers del pool.
  Future<void> initialize() async {
    if (isInitialized) return;

    for (int i = 0; i < size; i++) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(_poolWorker, receivePort.sendPort);
      final sendPort = await receivePort.first as SendPort;
      _workers.add(sendPort);
      _isolates.add(isolate); // Guardar referencia para cleanup
    }
  }

  /// Ejecutar una tarea en el siguiente worker disponible (round-robin).
  Future<double> execute(int iterations) async {
    if (!isInitialized) {
      throw StateError('Pool no inicializado. Llama a initialize()');
    }
    final worker = _workers[_nextWorker];
    _nextWorker = (_nextWorker + 1) % size;

    final responsePort = ReceivePort();
    worker.send([iterations, responsePort.sendPort]);
    return await responsePort.first as double;
  }

  /// Ejecutar múltiples tareas distribuyéndolas entre los workers.
  Future<List<double>> executeAll(List<int> tasks) async {
    final futures = tasks.map((task) => execute(task));
    return Future.wait(futures);
  }

  /// Detiene todos los workers y libera recursos.
  void dispose() {
    for (final isolate in _isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _isolates.clear();
    _workers.clear();
    _nextWorker = 0;
  }

  static void _poolWorker(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    port.listen((message) {
      final iterations = message[0] as int;
      final responseSendPort = message[1] as SendPort;

      double result = 0.0;
      for (int i = 0; i < iterations; i++) {
        result += i;
      }
      responseSendPort.send(result);
    });
  }
}
```

### Detalles clave del pool

| Concepto | Implementación | ¿Por qué? |
|---|---|---|
| Tamaño dinámico | `(Platform.numberOfProcessors - 1).clamp(1, 8)` | Se adapta al dispositivo, mínimo 1, máximo 8 |
| Tracking de isolates | `List<Isolate> _isolates` | Necesario para `dispose()` — si no guardas la referencia, no puedes matar el isolate |
| Guard de inicialización | `if (isInitialized) return` | Previene crear workers duplicados |
| Distribución round-robin | `_nextWorker = (_nextWorker + 1) % size` | Distribuye tareas equitativamente |
| `StateError` en `execute` | `if (!isInitialized) throw` | Falla rápido si olvidas `initialize()` |

### Demo: 4 tareas en paralelo

En la demo real (`lib/pages/pool_page.dart`), se ejecutan 4 tareas pesadas con medición de tiempo:

```dart
// 📂 lib/pages/pool_page.dart (fragmento clave)
Future<void> _runDemo() async {
  _pool = IsolatePool();      // Usa Platform.numberOfProcessors - 1
  await _pool!.initialize();

  setState(() {
    _poolSize = _pool!.size;
    _status = '⏳ Pool de $_poolSize workers listo. Ejecutando 4 tareas...';
  });

  final stopwatch = Stopwatch()..start();

  // 4 tareas pesadas en paralelo 🚀
  final tasks = [200000000, 300000000, 400000000, 500000000];
  final results = await _pool!.executeAll(tasks);

  stopwatch.stop();
  // Resultado: "✅ 4 tareas completadas en {X}ms"

  _pool?.dispose();
}
```

### ¿Cuántos isolates en el pool?

| Dispositivo | Cores | Pool automático (`numberOfProcessors - 1`) |
|---|---|---|
| iPhone 15 | 6 cores | 5 workers |
| Pixel 8 | 8 cores | 7 workers (clamped a 8 max) |
| Budget Android | 4 cores | 3 workers |
| Simulador/PC | 8-16 cores | 7-8 workers (clamped) |

:::tip Regla general
Nuestro pool usa `(Platform.numberOfProcessors - 1).clamp(1, 8)` automáticamente. Dejas 1 core libre para el main isolate, con un tope de 8 para no sobrecargar dispositivos potentes.
:::

## 🛡 Error Handling

¿Qué pasa si el isolate lanza una excepción? Sin error handling, tu app se crashea silenciosamente. Evolucionemos nuestro ejemplo:

### Capturar errores del isolate

```dart
// 📂 lib/isolates/safe_isolate.dart
import 'dart:async';
import 'dart:isolate';

class SafeIsolate {
  /// Ejecuta un cómputo pesado capturando errores del isolate.
  static Future<double> safeHeavyProcess(int iterations) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort(); // ⬅️ Puerto para errores

    await Isolate.spawn(
      _worker,
      [iterations, receivePort.sendPort],
      onError: errorPort.sendPort, // ⬅️ Capturar errores
    );

    final completer = Completer<double>();

    // Escuchar errores del isolate
    errorPort.listen((error) {
      if (!completer.isCompleted) {
        completer.completeError(
          IsolateException(
            message: error[0].toString(),
            stackTrace: error[1].toString(),
          ),
        );
      }
      receivePort.close();
      errorPort.close();
    });

    // Escuchar resultados exitosos
    receivePort.listen((result) {
      if (!completer.isCompleted) {
        completer.complete(result as double);
      }
      receivePort.close();
      errorPort.close();
    });

    return completer.future;
  }

  /// Worker que valida la entrada antes de procesar.
  static void _worker(List<dynamic> args) {
    final iterations = args[0] as int;
    final sendPort = args[1] as SendPort;

    // Validación que lanza error si iterations < 0
    if (iterations < 0) {
      throw ArgumentError(
        'Las iteraciones no pueden ser negativas: $iterations',
      );
    }

    double result = 0.0;
    for (int i = 0; i < iterations; i++) {
      result += i;
    }
    sendPort.send(result);
  }
}

/// Excepción personalizada para errores dentro de isolates.
class IsolateException implements Exception {
  final String message;
  final String stackTrace;

  IsolateException({required this.message, required this.stackTrace});

  @override
  String toString() => 'IsolateException: $message';
}
```

### Detalles clave del error handling

**Guard `!completer.isCompleted`**: Tanto el listener de errores como el de resultados verifican que el `Completer` no se haya completado antes de llamar a `complete()` o `completeError()`. Esto previene la excepción `StateError: Future already completed` que ocurre si ambos listeners intentan completar el mismo `Completer`.

**`IsolateException` personalizada**: En lugar de lanzar una `Exception` genérica, envolvemos el error en `IsolateException` que incluye tanto el `message` como el `stackTrace` del isolate. Esto facilita enormemente el debugging en producción.

### Demo: éxito y error forzado

La demo real (`lib/pages/error_handling_page.dart`) tiene **2 botones** para probar ambos escenarios:

```dart
// 📂 lib/pages/error_handling_page.dart (fragmento clave)

// ✅ Éxito: 500M iteraciones válidas
Future<void> _runSuccess() async {
  try {
    final result = await SafeIsolate.safeHeavyProcess(500000000);
    setState(() {
      _result = result.toStringAsExponential(4);
      _status = '✅ Éxito — el isolate completó sin errores';
    });
  } catch (e) {
    setState(() => _status = '❌ Error capturado: $e');
  }
}

// ❌ Error forzado: -1 iteraciones (ArgumentError)
Future<void> _runWithError() async {
  try {
    final result = await SafeIsolate.safeHeavyProcess(-1); // ¡Error!
    setState(() => _result = result.toStringAsExponential(4));
  } catch (e) {
    setState(() {
      _lastWasError = true;
      _status = '🛡 Error capturado correctamente';
      _result = e.toString(); // "IsolateException: ..."
    });
  }
}
```

La UI muestra el error con un `Card` de color `errorContainer` para distinguirlo visualmente del resultado exitoso.

## ⚡ Alternativa: `compute()`

Si no necesitas toda la flexibilidad de `Isolate.spawn()`, Flutter ofrece `compute()` que simplifica todo:

```dart
// 📂 lib/isolates/compute_example.dart
import 'package:flutter/foundation.dart';

class ComputeExample {
  /// Ejecuta un cómputo pesado usando [compute].
  ///
  /// Esta es la forma más sencilla de mover trabajo pesado
  /// a un isolate separado. Una sola línea hace todo el trabajo.
  static Future<double> run(int iterations) async {
    return await compute(_heavyProcess, iterations);
  }

  /// La función que se ejecuta en el isolate.
  ///
  /// REQUISITOS:
  /// - Debe ser top-level o static (no puede acceder a `this`)
  /// - Recibe exactamente un argumento
  /// - El argumento y el retorno deben ser serializables
  static double _heavyProcess(int iterations) {
    double result = 0.0;
    for (int i = 0; i < iterations; i++) {
      result += i;
    }
    return result;
  }
}
```

### Demo: `compute_page.dart`

La demo incluye medición de tiempo para comparar con los otros patrones:

```dart
// 📂 lib/pages/compute_page.dart (fragmento clave)
Future<void> _runDemo() async {
  final stopwatch = Stopwatch()..start();
  final result = await ComputeExample.run(1000000000);
  stopwatch.stop();

  setState(() {
    _result = result.toStringAsExponential(4);
    _duration = stopwatch.elapsed;
    _status = '✅ Completado en ${_duration.inMilliseconds}ms';
  });
}
```

### Comparación completa

| Característica | `compute()` | `Isolate.spawn()` | Pool |
|---|---|---|---|
| Líneas de código | ~3 | ~15 | ~50 |
| Comunicación | Solo retorno | Bidireccional | Bidireccional |
| Reutilizable | ❌ Muere al terminar | ✅ Opcional | ✅ Sí |
| Progreso | ❌ No | ✅ Sí | ✅ Sí |
| Múltiples tareas | ❌ Secuencial | ⚠️ Manual | ✅ Paralelo |
| Error handling | ✅ Automático | ⚠️ Manual | ⚠️ Manual |
| Overhead | Alto (crea/destruye) | Bajo (si reutilizas) | Mínimo |
| **Cuándo usarlo** | Operación única | Worker persistente | Muchas tareas |

## 🧠 Mejores Prácticas

### ✅ Hacer

```dart
// ✅ Funciones top-level o static para isolates
static void myWorker(SendPort sendPort) { ... }

// ✅ Siempre cerrar los ports cuando termines
receivePort.close();

// ✅ Manejar errores con onError
await Isolate.spawn(worker, port, onError: errorPort.sendPort);

// ✅ Guard para evitar doble inicialización
if (isRunning) return;

// ✅ Guardar referencia al Isolate para poder hacer dispose
Isolate? _isolate;
_isolate = await Isolate.spawn(...);

// ✅ Verificar !completer.isCompleted antes de completar
if (!completer.isCompleted) {
  completer.complete(result);
}
```

### ❌ No hacer

```dart
// ❌ No pases closures a isolates
Isolate.spawn((port) { ... }, sendPort); // Error!

// ❌ No envíes objetos enormes entre isolates
sendPort.send(listaConMillonesDeElementos); // Lento 🐌

// ❌ No olvides dispose de isolates persistentes
// Si no lo haces, consumen memoria para siempre

// ❌ No accedas a plugins de Flutter desde isolates
// Los plugins necesitan el main isolate (platform channels)

// ❌ No crees isolates sin guardar la referencia
await Isolate.spawn(worker, port); // ¿Cómo lo detienes?
```

## 🏗 Arquitectura del proyecto `advanced_isolates`

```
advanced_isolates/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp con tema Weincode
│   ├── isolates/
│   │   ├── bidirectional_isolate.dart     # 🔄 Comunicación bidireccional
│   │   ├── persistent_worker.dart         # 🔁 Worker de larga vida
│   │   ├── progress_isolate.dart          # 📊 Reporte de progreso
│   │   ├── isolate_pool.dart              # 🏊 Pool de workers
│   │   ├── safe_isolate.dart              # 🛡 Error handling seguro
│   │   └── compute_example.dart           # ⚡ compute() simplificado
│   ├── pages/
│   │   ├── home_page.dart                 # Menú principal con 6 patrones
│   │   ├── bidirectional_page.dart        # Demo: 2 tareas al mismo isolate
│   │   ├── persistent_page.dart           # Demo: worker con 3 botones de carga
│   │   ├── progress_page.dart             # Demo: barra de progreso real-time
│   │   ├── pool_page.dart                 # Demo: 4 tareas paralelas con timing
│   │   ├── error_handling_page.dart       # Demo: éxito vs error forzado
│   │   └── compute_page.dart              # Demo: compute() con timing
│   └── widgets/
│       ├── cat_gif.dart                   # 🐱 GIF indicador de fluidez
│       └── result_card.dart               # Card reutilizable para resultados
└── assets/images/gif/cat.gif              # El gato que no debe congelarse
```

## 📝 Resumen del módulo

Partiendo del proyecto `intro_isolates`, hemos aprendido:

| Nivel | Concepto | Archivo en `advanced_isolates` | Demo |
|---|---|---|---|
| 🟢 Problema | Bloqueo de UI con cómputo pesado | `intro_isolates/home_page.dart` | — |
| 🟢 Solución básica | `Isolate.spawn()` con `SendPort` | `intro_isolates/isolate_example.dart` | — |
| 🟡 Bidireccional | Handshake + `switch` de comandos | `lib/isolates/bidirectional_isolate.dart` | `bidirectional_page.dart` |
| 🟡 Persistente | `if (isRunning) return` + `dispose()` | `lib/isolates/persistent_worker.dart` | `persistent_page.dart` |
| 🟡 Progreso | `_WorkerConfig` + triple guard | `lib/isolates/progress_isolate.dart` | `progress_page.dart` |
| 🔴 Pool | `clamp(1, 8)` + `List<Isolate>` | `lib/isolates/isolate_pool.dart` | `pool_page.dart` |
| 🔴 Errores | `IsolateException` + `!isCompleted` | `lib/isolates/safe_isolate.dart` | `error_handling_page.dart` |
| 🟢 Simple | `compute()` wrapper | `lib/isolates/compute_example.dart` | `compute_page.dart` |

:::info ¿Quieres ver el código funcionando?
Todos los patrones avanzados están implementados en el proyecto `advanced_isolates`:

```bash
git clone https://github.com/weincoder/flutter-avanzado.git
cd flutter-avanzado/isolates/advanced_isolates
flutter pub get
flutter run
```

Cada patrón tiene su propia pantalla interactiva. Observa el 🐱 GIF del gato — es tu mejor indicador de rendimiento.

¿Quieres entender los conceptos básicos primero? Empieza con el proyecto `intro_isolates`:

```bash
cd flutter-avanzado/isolates/intro_isolates
flutter pub get
flutter run
```
:::
