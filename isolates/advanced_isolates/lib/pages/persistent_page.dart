import 'package:flutter/material.dart';

import '../isolates/persistent_worker.dart';
import '../widgets/cat_gif.dart';
import '../widgets/result_card.dart';

/// Demo del patrón Worker Persistente.
///
/// El worker se inicia con el widget y se reutiliza para múltiples
/// tareas durante todo su ciclo de vida.
class PersistentPage extends StatefulWidget {
  const PersistentPage({super.key});

  @override
  State<PersistentPage> createState() => _PersistentPageState();
}

class _PersistentPageState extends State<PersistentPage> {
  final _worker = PersistentWorker();
  String _status = 'Iniciando worker...';
  int _taskCount = 0;
  String _lastResult = '--';
  bool _isRunning = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initWorker();
  }

  Future<void> _initWorker() async {
    await _worker.start();
    if (mounted) {
      setState(() {
        _isReady = true;
        _status = '✅ Worker listo — envía tareas!';
      });
    }
  }

  @override
  void dispose() {
    _worker.dispose(); // ⚠️ Siempre limpiar recursos
    super.dispose();
  }

  Future<void> _runTask(int iterations) async {
    setState(() {
      _isRunning = true;
      _status = '⏳ Procesando ${_formatNumber(iterations)} iteraciones...';
    });

    try {
      final result = await _worker.execute(iterations);
      _taskCount++;
      setState(() {
        _lastResult = result.toStringAsExponential(4);
        _status = '✅ Tarea #$_taskCount completada (mismo worker)';
      });
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000000000) return '${n ~/ 1000000000}B';
    if (n >= 1000000) return '${n ~/ 1000000}M';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔁 Worker Persistente')),
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
                  child: ResultCard(
                    label: 'Tareas ejecutadas',
                    value: '$_taskCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResultCard(
                    label: 'Último resultado',
                    value: _lastResult,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: !_isReady || _isRunning
                      ? null
                      : () => _runTask(100000000),
                  child: const Text('100M iteraciones'),
                ),
                FilledButton(
                  onPressed: !_isReady || _isRunning
                      ? null
                      : () => _runTask(500000000),
                  child: const Text('500M iteraciones'),
                ),
                FilledButton(
                  onPressed: !_isReady || _isRunning
                      ? null
                      : () => _runTask(1000000000),
                  child: const Text('1B iteraciones'),
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
              '1. El worker se crea en initState()\n'
              '2. Puedes enviar múltiples tareas sin recrear el isolate\n'
              '3. Se ahorra el overhead de crear/destruir (~50-150ms)\n'
              '4. Se destruye en dispose() al salir de la página\n'
              '5. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
