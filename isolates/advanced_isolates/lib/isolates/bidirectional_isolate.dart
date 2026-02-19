import 'dart:isolate';

/// Comunicación bidireccional entre el main isolate y un worker.
///
/// A diferencia de [Isolate.spawn] básico (donde solo el worker puede
/// enviar mensajes de vuelta), aquí ambos lados pueden enviarse mensajes
/// en cualquier momento.
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-comunicación-bidireccional
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
