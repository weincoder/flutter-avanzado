import 'dart:isolate';

/// Worker persistente que vive durante todo el ciclo de vida del widget.
///
/// A diferencia de [compute()] o un [Isolate.spawn] de una sola vez,
/// este worker se crea una vez y se reutiliza para múltiples tareas,
/// ahorrando el overhead de crear/destruir isolates (~50-150ms cada vez).
///
/// ⚠️ IMPORTANTE: Siempre llama a [dispose] cuando ya no lo necesites.
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-isolate-de-larga-vida
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
  ///
  /// Después de llamar a dispose, debes llamar a [start] de nuevo
  /// antes de poder ejecutar más tareas.
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
