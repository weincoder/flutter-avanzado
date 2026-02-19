import 'dart:async';
import 'package:flutter/material.dart';

import '../isolates/progress_isolate.dart';
import '../widgets/cat_gif.dart';

/// Demo de isolate con reporte de progreso en tiempo real.
///
/// Muestra una barra de progreso que se actualiza mientras
/// el isolate ejecuta el cómputo pesado.
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _progress = 0.0;
  String _status = 'Listo para iniciar';
  String _result = '--';
  bool _isRunning = false;
  StreamSubscription<double>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _runDemo() {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
      _result = '--';
      _status = '⏳ Procesando...';
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
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _status = '❌ Error: $e';
          _isRunning = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('📊 Progreso en Tiempo Real')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CatGif(),
            const SizedBox(height: 16),
            Text(
              _status,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 24,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Resultado
            Card(
              child: ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Resultado'),
                subtitle: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _isRunning ? null : _runDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar (1B iteraciones)'),
            ),
            const SizedBox(height: 24),
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
              '1. El isolate ejecuta 1 billón de iteraciones\n'
              '2. Cada 1% envía el progreso por el SendPort\n'
              '3. El main isolate recibe un Stream<double>\n'
              '4. setState() actualiza la barra de progreso\n'
              '5. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
