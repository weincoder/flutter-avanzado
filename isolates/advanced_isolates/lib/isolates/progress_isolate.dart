import 'dart:isolate';

/// Isolate que reporta progreso mientras ejecuta un cómputo pesado.
///
/// Envía valores de tipo [double] por un [Stream]:
/// - Valores entre 0.0 y 1.0 representan el progreso (0% a 100%).
/// - El último valor (mayor a 1.0) es el resultado final del cómputo.
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-reportar-progreso
class ProgressIsolate {
  /// Ejecuta el cómputo pesado reportando progreso como un [Stream].
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final stream = ProgressIsolate.heavyProcessWithProgress(1000000000);
  /// stream.listen((value) {
  ///   if (value <= 1.0) {
  ///     // Es progreso: 0.0 a 1.0
  ///   } else {
  ///     // Es el resultado final
  ///   }
  /// });
  /// ```
  static Stream<double> heavyProcessWithProgress(int totalIterations) {
    final receivePort = ReceivePort();

    Isolate.spawn(
      _worker,
      _WorkerConfig(
        sendPort: receivePort.sendPort,
        totalIterations: totalIterations,
      ),
    );

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
        config.sendPort.send(progress);
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
