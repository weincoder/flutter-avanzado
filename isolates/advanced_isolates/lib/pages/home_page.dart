import 'package:flutter/material.dart';

import 'bidirectional_page.dart';
import 'persistent_page.dart';
import 'progress_page.dart';
import 'pool_page.dart';
import 'error_handling_page.dart';
import 'compute_page.dart';

/// Página principal con la lista de todos los patrones avanzados de isolates.
///
/// Cada tarjeta navega a una página dedicada que demuestra un patrón
/// específico con el GIF del gato como indicador visual.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧶 Advanced Isolates'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/gif/cat.gif',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 12),
                Text(
                  'Patrones Avanzados de Isolates',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Observa el GIF del gato 🐱 en cada demo.\n'
                  'Si se congela, la UI está bloqueada.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Pattern cards
          _PatternCard(
            icon: '🔄',
            title: 'Comunicación Bidireccional',
            subtitle: 'Enviar y recibir mensajes entre isolates',
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BidirectionalPage()),
            ),
          ),
          _PatternCard(
            icon: '🔁',
            title: 'Worker Persistente',
            subtitle: 'Reutilizar un isolate para múltiples tareas',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersistentPage()),
            ),
          ),
          _PatternCard(
            icon: '📊',
            title: 'Progreso en Tiempo Real',
            subtitle: 'Enviar actualizaciones parciales a la UI',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressPage()),
            ),
          ),
          _PatternCard(
            icon: '🏊',
            title: 'Pool de Isolates',
            subtitle: 'Ejecutar múltiples tareas en paralelo',
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PoolPage()),
            ),
          ),
          _PatternCard(
            icon: '🛡',
            title: 'Error Handling',
            subtitle: 'Manejar errores sin crashear la app',
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ErrorHandlingPage()),
            ),
          ),
          _PatternCard(
            icon: '⚡',
            title: 'compute() Simplificado',
            subtitle: 'La forma más fácil de usar isolates',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComputePage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PatternCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}
