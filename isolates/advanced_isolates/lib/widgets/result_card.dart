import 'package:flutter/material.dart';

/// Tarjeta para mostrar un resultado con su etiqueta.
class ResultCard extends StatelessWidget {
  final String label;
  final String value;

  const ResultCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
