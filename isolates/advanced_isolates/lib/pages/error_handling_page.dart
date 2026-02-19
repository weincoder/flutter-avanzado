import 'package:flutter/material.dart';

import '../isolates/safe_isolate.dart';
import '../widgets/cat_gif.dart';

/// Demo de manejo seguro de errores en isolates.
///
/// Muestra cómo capturar excepciones dentro de un isolate
/// sin que la app crashee silenciosamente.
class ErrorHandlingPage extends StatefulWidget {
  const ErrorHandlingPage({super.key});

  @override
  State<ErrorHandlingPage> createState() => _ErrorHandlingPageState();
}

class _ErrorHandlingPageState extends State<ErrorHandlingPage> {
  String _status = 'Listo para probar';
  String _result = '--';
  bool _isRunning = false;
  bool _lastWasError = false;

  Future<void> _runSuccess() async {
    setState(() {
      _isRunning = true;
      _lastWasError = false;
      _status = '⏳ Ejecutando con 500M iteraciones...';
      _result = '--';
    });

    try {
      final result = await SafeIsolate.safeHeavyProcess(500000000);
      setState(() {
        _result = result.toStringAsExponential(4);
        _status = '✅ Éxito — el isolate completó sin errores';
      });
    } catch (e) {
      setState(() {
        _lastWasError = true;
        _status = '❌ Error capturado: $e';
      });
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _runWithError() async {
    setState(() {
      _isRunning = true;
      _lastWasError = false;
      _status = '⏳ Ejecutando con -1 iteraciones (¡error!)...';
      _result = '--';
    });

    try {
      final result = await SafeIsolate.safeHeavyProcess(-1);
      setState(() {
        _result = result.toStringAsExponential(4);
        _status = '✅ Éxito (no debería llegar aquí)';
      });
    } catch (e) {
      setState(() {
        _lastWasError = true;
        _status = '🛡 Error capturado correctamente';
        _result = e.toString();
      });
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('🛡 Error Handling')),
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

            // Resultado / Error
            Card(
              color: _lastWasError ? theme.colorScheme.errorContainer : null,
              child: ListTile(
                leading: Icon(
                  _lastWasError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: _lastWasError ? theme.colorScheme.error : Colors.green,
                ),
                title: Text(_lastWasError ? 'Error capturado' : 'Resultado'),
                subtitle: Text(
                  _result,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: _lastWasError
                        ? theme.colorScheme.onErrorContainer
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRunning ? null : _runSuccess,
                    icon: const Icon(Icons.check),
                    label: const Text('Éxito (500M)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRunning ? null : _runWithError,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Forzar Error'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
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
              '1. "Éxito" ejecuta con 500M iteraciones → resultado normal\n'
              '2. "Forzar Error" usa -1 iteraciones → throw en el isolate\n'
              '3. Isolate.spawn(onError: errorPort) captura la excepción\n'
              '4. El Completer propaga el error como un Future.error\n'
              '5. try/catch en el main isolate lo captura sin crash\n'
              '6. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
