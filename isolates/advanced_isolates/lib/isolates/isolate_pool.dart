import 'dart:io';
import 'dart:isolate';

/// Pool de isolates que reutiliza un número fijo de workers.
///
/// Distribuye tareas con un algoritmo round-robin: cada nueva tarea
/// se asigna al siguiente worker en la lista circular.
///
/// Esto es más eficiente que crear un isolate por tarea cuando necesitas
/// ejecutar muchas operaciones pesadas en paralelo.
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-pool-de-isolates
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
  ///
  /// Debe llamarse antes de [execute] o [executeAll].
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    for (int i = 0; i < size; i++) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(_poolWorker, receivePort.sendPort);
      final sendPort = await receivePort.first as SendPort;
      _workers.add(sendPort);
      _isolates.add(isolate);
    }
  }

  /// Ejecuta una tarea en el siguiente worker disponible (round-robin).
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

  /// Ejecuta múltiples tareas distribuyéndolas entre los workers.
  ///
  /// Las tareas se ejecutan en paralelo (limitadas por el tamaño del pool).
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

  /// Función que ejecuta cada worker del pool.
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
