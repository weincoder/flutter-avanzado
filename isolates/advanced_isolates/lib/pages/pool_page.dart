import 'package:flutter/material.dart';

import '../isolates/isolate_pool.dart';
import '../widgets/cat_gif.dart';
import '../widgets/result_card.dart';

/// Demo del Pool de Isolates.
///
/// Crea N workers y distribuye múltiples tareas pesadas
/// entre ellos con round-robin.
class PoolPage extends StatefulWidget {
  const PoolPage({super.key});

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  IsolatePool? _pool;
  String _status = 'Listo para iniciar';
  List<String> _results = [];
  bool _isRunning = false;
  int _poolSize = 0;
  Duration _duration = Duration.zero;

  @override
  void dispose() {
    _pool?.dispose();
    super.dispose();
  }

  Future<void> _runDemo() async {
    setState(() {
      _isRunning = true;
      _results = [];
      _status = '🚀 Inicializando pool...';
    });

    try {
      _pool = IsolatePool();
      await _pool!.initialize();

      setState(() {
        _poolSize = _pool!.size;
        _status = '⏳ Pool de $_poolSize workers listo. Ejecutando 4 tareas...';
      });

      final stopwatch = Stopwatch()..start();

      // 4 tareas pesadas en paralelo
      final tasks = [200000000, 300000000, 400000000, 500000000];
      final results = await _pool!.executeAll(tasks);

      stopwatch.stop();

      setState(() {
        _results = results.map((r) => r.toStringAsExponential(3)).toList();
        _duration = stopwatch.elapsed;
        _status = '✅ 4 tareas completadas en ${_duration.inMilliseconds}ms';
      });
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      _pool?.dispose();
      _pool = null;
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏊 Pool de Isolates')),
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

            if (_poolSize > 0)
              ResultCard(label: 'Workers en el pool', value: '$_poolSize'),
            const SizedBox(height: 8),

            if (_results.isNotEmpty) ...[
              const Text(
                'Resultados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_results.length, (i) {
                final taskSizes = ['200M', '300M', '400M', '500M'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withValues(alpha: 0.1),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text('Tarea ${taskSizes[i]} iteraciones'),
                    subtitle: Text(
                      _results[i],
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              ResultCard(
                label: 'Tiempo total',
                value: '${_duration.inMilliseconds}ms',
              ),
            ],

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isRunning ? null : _runDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ejecutar 4 Tareas en Paralelo'),
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
              '1. Se crea un pool con N workers (cores - 1)\n'
              '2. Se envían 4 tareas pesadas simultáneamente\n'
              '3. Las tareas se distribuyen con round-robin\n'
              '4. Future.wait() espera a que todas terminen\n'
              '5. El GIF nunca se congela 🐱',
            ),
          ],
        ),
      ),
    );
  }
}
