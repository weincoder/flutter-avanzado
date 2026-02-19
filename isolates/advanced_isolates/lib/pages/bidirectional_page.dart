import 'package:flutter/material.dart';

import '../isolates/bidirectional_isolate.dart';
import '../widgets/cat_gif.dart';
import '../widgets/result_card.dart';

/// Demo de comunicación bidireccional entre isolates.
///
/// Muestra cómo enviar múltiples comandos al mismo isolate
/// y recibir respuestas individuales para cada uno.
class BidirectionalPage extends StatefulWidget {
  const BidirectionalPage({super.key});

  @override
  State<BidirectionalPage> createState() => _BidirectionalPageState();
}

class _BidirectionalPageState extends State<BidirectionalPage> {
  final _isolate = BidirectionalIsolate();
  String _status = 'Listo para iniciar';
  String _result1 = '--';
  String _result2 = '--';
  bool _isRunning = false;

  @override
  void dispose() {
    _isolate.dispose();
    super.dispose();
  }

  Future<void> _runDemo() async {
    setState(() {
      _isRunning = true;
      _status = '🚀 Iniciando isolate...';
      _result1 = '--';
      _result2 = '--';
    });

    try {
      // Paso 1: Iniciar el isolate (handshake bidireccional)
      await _isolate.start();
      setState(() => _status = '🔄 Enviando tarea 1...');

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
      _isolate.dispose();
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔄 Bidireccional')),
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
                  child: ResultCard(label: 'Tarea 1 (500M)', value: _result1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultCard(label: 'Tarea 2 (1B)', value: _result2),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isRunning ? null : _runDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ejecutar Demo'),
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
              '1. Se crea un isolate con handshake bidireccional\n'
              '2. Ambos lados intercambian SendPorts\n'
              '3. Se envía la tarea 1 → se recibe resultado\n'
              '4. Se reutiliza el MISMO isolate para tarea 2\n'
              '5. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
