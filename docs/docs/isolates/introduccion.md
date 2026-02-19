---
sidebar_position: 1
---

# Introducción a Isolates

Los isolates son la forma en que Dart implementa la concurrencia. Cada isolate es un hilo de ejecución aislado con su propio heap de memoria.

## ¿Por qué Isolates?

En Dart, el modelo de concurrencia se basa en isolates porque:

1. **Seguridad de Memoria**: Cada isolate tiene su propio heap, evitando race conditions
2. **Rendimiento**: No hay contención de locks como en otros lenguajes
3. **Simplicidad**: Comunicación basada en paso de mensajes

## Conceptos Clave

### Main Isolate

Tu aplicación Flutter comienza en el main isolate, donde se ejecuta todo el código de la UI.

### Event Loop

El main isolate ejecuta código en un modelo de event loop:

```
┌─────────────────────────────────┐
│     Ejecuta Código Síncrono     │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│   Procesa Eventos y Callbacks   │
└─────────────────────────────────┘
              ↓
         (Repite)
```

### Bloqueo del Main Isolate

Si el main isolate se bloquea, toda la UI se congela:

```dart
// ❌ MAL - Bloquea la UI
void procesarDatos() {
  for (int i = 0; i < 1000000000; i++) {
    // Operación pesada
  }
}

// ✅ BIEN - Usa un isolate
import 'dart:isolate';

void procesarDatos() async {
  await compute(operacionPesada, null);
}

void operacionPesada(dynamic _) {
  for (int i = 0; i < 1000000000; i++) {
    // Operación pesada
  }
}
```

## Casos de Uso

1. **Procesamiento de imágenes**: Redimensionar, filtrar
2. **Cálculos complejos**: Análisis de datos, criptografía
3. **JSON parsing**: Para datos grandes
4. **Video/Audio**: Encoding, decoding

## Ventajas y Desventajas

### Ventajas ✅
- Evita bloqueos de UI
- Seguro contra race conditions
- Fácil de razonar

### Desventajas ❌
- Comunicación lenta entre isolates
- Overhead de creación
- Complejidad adicional

## Próximos Pasos

En las siguientes secciones aprenderás:
- Cómo crear isolates básicos
- Patrones avanzados de comunicación
- Mejores prácticas y optimización
