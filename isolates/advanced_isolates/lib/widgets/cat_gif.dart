import 'package:flutter/material.dart';

/// Widget que muestra el GIF del gato como indicador visual de bloqueo.
///
/// Si la UI está bloqueada por un cómputo pesado en el main isolate,
/// el GIF se congela. Si el cómputo está en un isolate separado,
/// el GIF sigue animándose normalmente.
class CatGif extends StatelessWidget {
  final double size;

  const CatGif({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/gif/cat.gif',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '🐱 Si el GIF se congela, la UI está bloqueada',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
