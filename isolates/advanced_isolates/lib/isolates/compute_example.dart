import 'package:flutter/foundation.dart';

/// Ejemplo usando [compute] de Flutter - la forma más simple de usar isolates.
///
/// [compute] es una abstracción de alto nivel que:
/// 1. Crea un isolate nuevo
/// 2. Ejecuta la función dada
/// 3. Recibe el resultado
/// 4. Cierra el isolate automáticamente
///
/// Es ideal para operaciones únicas "fire-and-forget".
///
/// 📖 Documentación: https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado#-alternativa-compute
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
