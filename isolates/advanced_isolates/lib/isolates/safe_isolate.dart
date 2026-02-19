import 'dart:async';
import 'dart:isolate';

/// Isolate con manejo seguro de errores.
///
/// Usa [onError] para capturar excepciones dentro del isolate
/// sin que crasheen la aplicación silenciosamente.
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-error-handling
class SafeIsolate {
  /// Ejecuta un cómputo pesado capturando errores del isolate.
  ///
  /// Si [iterations] es negativo, el isolate lanzará un [ArgumentError]
  /// que será capturado y propagado como una [Exception] normal.
  static Future<double> safeHeavyProcess(int iterations) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    await Isolate.spawn(_worker, [
      iterations,
      receivePort.sendPort,
    ], onError: errorPort.sendPort);

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
