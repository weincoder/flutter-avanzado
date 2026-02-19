import 'package:flutter/material.dart';

import '../isolates/compute_example.dart';
import '../widgets/cat_gif.dart';
import '../widgets/result_card.dart';

/// Demo de compute() — la forma más simple de usar isolates.
///
/// Compara la simplicidad de compute() con los patrones más complejos.
class ComputePage extends StatefulWidget {
  const ComputePage({super.key});

  @override
  State<ComputePage> createState() => _ComputePageState();
}

class _ComputePageState extends State<ComputePage> {
  String _status = 'Listo para iniciar';
  String _result = '--';
  bool _isRunning = false;
  Duration _duration = Duration.zero;

  Future<void> _runDemo() async {
    setState(() {
      _isRunning = true;
      _status = '⏳ compute() trabajando...';
      _result = '--';
    });

    try {
      final stopwatch = Stopwatch()..start();
      final result = await ComputeExample.run(1000000000);
      stopwatch.stop();

      setState(() {
        _result = result.toStringAsExponential(4);
        _duration = stopwatch.elapsed;
        _status = '✅ Completado en ${_duration.inMilliseconds}ms';
      });
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚡ compute()')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CatGif(),
            const SizedBox(height: 16),
            Text(
              _status,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ResultCard(label: 'Resultado', value: _result),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultCard(
                    label: 'Tiempo',
                    value: _duration.inMilliseconds > 0
                        ? '${_duration.inMilliseconds}ms'
                        : '--',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _isRunning ? null : _runDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('compute(heavyProcess, 1B)'),
            ),
            const SizedBox(height: 24),

            // Código ejemplo
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Código',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'final result = await compute(\n'
                      '  heavyProcess,\n'
                      '  1000000000,\n'
                      ');\n\n'
                      '// ¡Solo 1 línea para usar un isolate!',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildExplanation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 ¿Qué está pasando?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. compute() crea un isolate automáticamente\n'
              '2. Ejecuta la función con el argumento dado\n'
              '3. Recibe el resultado de vuelta\n'
              '4. Destruye el isolate automáticamente\n'
              '5. Ideal para operaciones únicas "fire-and-forget"\n'
              '6. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
