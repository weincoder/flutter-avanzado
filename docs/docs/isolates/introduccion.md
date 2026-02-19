---
sidebar_position: 1
---

# Introducción a Isolates

Los **isolates** son la forma en que Dart implementa la concurrencia. Cada isolate es un hilo de ejecución aislado con su propio heap de memoria, lo que significa que **no comparten estado** entre ellos.

En este módulo usaremos el proyecto [`intro_isolates`](https://github.com/weincoder/flutter-avanzado/tree/main/isolates/intro_isolates) como ejemplo práctico para entender cómo y cuándo usarlos.

## 🎯 ¿Qué aprenderás?

- Qué es un isolate y cómo funciona el event loop de Dart
- Por qué un cómputo pesado **congela** tu app
- Cómo mover trabajo pesado a un isolate separado
- Comunicación entre isolates con `SendPort` y `ReceivePort`

## 🐱 El proyecto: intro_isolates

Nuestro ejemplo es una app Flutter sencilla con una animación GIF de un gato y dos botones:

| Botón | Qué hace | ¿La UI se congela? |
|---|---|---|
| **Heavy Process** | Ejecuta 1 billón de iteraciones en el **main isolate** | ✅ Sí, el GIF se congela |
| **Run Isolate Example** | Ejecuta el mismo cálculo en un **isolate separado** | ❌ No, el GIF sigue animándose |

> 💡 **La clave**: El GIF animado actúa como un indicador visual del estado del hilo principal. Si se congela, significa que el main isolate está bloqueado.

### Estructura del proyecto

```
intro_isolates/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── app.dart               # MaterialApp
│   ├── home_page.dart         # UI con los dos botones + GIF
│   └── isolate_example.dart   # Clase con el cómputo en isolate
└── assets/
    └── images/gif/
        └── cat.gif            # Indicador visual de bloqueo
```

## 🧠 ¿Por qué Isolates?

En Dart, **todo tu código se ejecuta en un solo hilo** llamado el **main isolate**. Esto incluye:

- El renderizado de la UI (60/120 fps)
- Los event handlers (taps, gestures)
- Las operaciones asíncronas (`Future`, `async/await`)

### El Event Loop

```
┌─────────────────────────────────────┐
│     Ejecuta Código Síncrono         │
│     (build, layout, paint)          │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│   Procesa Microtasks y Events       │
│   (Future callbacks, timers, I/O)   │
└─────────────────────────────────────┘
                  ↓
              (Repite)
```

> ⚠️ **Importante**: `async/await` **no crea hilos nuevos**. Solo programa callbacks en el event loop del **mismo** isolate. Si tu `Future` contiene un `for` de mil millones de iteraciones, el main isolate se bloquea igual.

### El problema: bloquear el main isolate

Así es como nuestro proyecto demuestra el problema. En `home_page.dart`, el método `heavyProcess()` ejecuta un cálculo pesado directamente en el main isolate:

```dart
// 📂 lib/home_page.dart

// ❌ PROBLEMA: Esto bloquea la UI completamente
Future<double> heavyProcess() async {
  print("Comienza el cómputo pesado...");
  double result = 0.0;
  for (int i = 0; i < 1000000000; i++) {
    result += i; // Operación ficticia
  }
  print("El cómputo pesado ha terminado.");
  return result;
}
```

Aunque la función es `async` y retorna un `Future`, **el `for` loop es síncrono** y bloquea completamente el event loop. Resultado: el GIF del gato se congela, los botones no responden, la app parece muerta.

### La solución: mover el cómputo a otro isolate

La misma operación, pero ejecutada en un isolate separado, no bloquea la UI:

```dart
// 📂 lib/isolate_example.dart

import 'dart:isolate';

class IsolateExample {
  static heavyProcess(SendPort sendPort) {
    print("Comienza el cómputo pesado... Isolate");
    double result = 0.0;
    for (int i = 0; i < 1000000000; i++) {
      result += i;
    }
    sendPort.send(result);
    print("El cómputo pesado ha terminado. Isolate");
  }
}
```

El GIF sigue animándose mientras el isolate trabaja en segundo plano. Cuando termina, envía el resultado de vuelta al main isolate a través del `SendPort`.

## 🔑 Conceptos Clave

| Concepto | Descripción |
|---|---|
| **Isolate** | Hilo de ejecución con su propia memoria (heap). No comparte estado. |
| **Main Isolate** | El isolate donde corre tu app Flutter (UI, events). |
| **SendPort** | Canal para **enviar** mensajes a otro isolate. |
| **ReceivePort** | Canal para **recibir** mensajes de otros isolates. |
| **Event Loop** | Ciclo que procesa código síncrono y callbacks en un isolate. |

## 📦 Casos de Uso Reales

| Caso de Uso | Ejemplo |
|---|---|
| 🧮 Cálculos intensivos | Algoritmos matemáticos, simulaciones |
| 🖼 Procesamiento de imágenes | Redimensionar, aplicar filtros, compresión |
| 📊 Parsing de datos grandes | JSON/XML de APIs con miles de registros |
| 🔐 Criptografía | Hashing, encriptación/desencriptación |
| 🎬 Audio/Video | Encoding, decoding, transformaciones |

## ✅ Ventajas y ❌ Desventajas

### Ventajas
- 🚀 La UI nunca se congela
- 🔒 Sin race conditions (no hay memoria compartida)
- 🧩 Fácil de razonar sobre el flujo de datos

### Desventajas
- 📨 La comunicación es por paso de mensajes (serialización)
- ⏱ Overhead de creación de isolates (~50-150ms)
- 🧠 Mayor complejidad en el código

## 🗺 Próximos Pasos

| Sección | Contenido |
|---|---|
| [Isolates Básico](./basico) | Desglose completo del código de `intro_isolates`: `Isolate.spawn()`, `ReceivePort`, flujo de comunicación |
| [Isolates Avanzado](./avanzado) | Comunicación bidireccional, pool de isolates, Streams, y cómo evolucionar el proyecto |
