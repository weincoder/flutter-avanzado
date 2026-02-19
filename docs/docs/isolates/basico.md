---
sidebar_position: 2
---

# Isolates Básico — Desglose del proyecto `intro_isolates`

En esta sección vamos a analizar **línea por línea** el código del proyecto [`intro_isolates`](https://github.com/weincoder/flutter-avanzado/tree/main/isolates/intro_isolates) para entender cómo crear y usar isolates en Flutter.

## 📂 Punto de entrada: `main.dart`

```dart
// 📂 lib/main.dart
import 'package:flutter/material.dart';
import 'package:intro_isolates/app.dart';

void main() {
  runApp(const App());
}
```

Nada especial aquí. Flutter inicia en el **main isolate** y ejecuta nuestra app.

## 📂 La app: `app.dart`

```dart
// 📂 lib/app.dart
import 'package:flutter/material.dart';
import 'package:intro_isolates/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates Intro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
```

Un `MaterialApp` estándar que carga nuestra `HomePage`.

## 📂 El corazón del ejemplo: `home_page.dart`

Aquí está lo interesante. Analicemos sección por sección:

### La UI: GIF + Dos botones

```dart
// 📂 lib/home_page.dart
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:intro_isolates/isolate_example.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolates Intro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to the Isolates Intro!'),
            const SizedBox(height: 20),

            // 🐱 El GIF: nuestro "detector de bloqueo"
            Image.asset(
              'assets/images/gif/cat.gif',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),

            // ❌ Botón 1: Proceso pesado en el main isolate
            ElevatedButton(
              onPressed: () { /* ... */ },
              child: const Text('Heavy Process'),
            ),
            const SizedBox(height: 20),

            // ✅ Botón 2: Proceso pesado en un isolate separado
            ElevatedButton(
              onPressed: () async { /* ... */ },
              child: const Text('Run Isolate Example'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> 🐱 **¿Por qué un GIF?** Los GIF animados son renderizados frame por frame por el main isolate. Si el main isolate está ocupado con un cálculo pesado, **no puede renderizar los frames del GIF**, y este se congela visualmente. Es la forma más simple de demostrar el bloqueo.

### Botón 1: Heavy Process (❌ Bloquea la UI)

```dart
ElevatedButton(
  onPressed: () {
    heavyProcess().then((result) {
      print("Heavy process completed with result: $result");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Heavy process result: $result")),
      );
    });
  },
  child: const Text('Heavy Process'),
),
```

Este botón llama a `heavyProcess()`, que se define así:

```dart
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

#### ¿Qué sucede paso a paso?

```
1. Tap en "Heavy Process"
2. Se invoca heavyProcess()
3. El for-loop de 1 BILLÓN de iteraciones comienza
4. ⚠️ El event loop queda BLOQUEADO
5. 🐱 El GIF se congela
6. ❌ Los botones no responden
7. ❌ No se pueden procesar gestures ni frames
8. ... (varios segundos después)
9. El for-loop termina
10. Se muestra el SnackBar con el resultado
11. 🐱 El GIF vuelve a animarse
```

:::caution Trampa común
La función es `async` y retorna un `Future<double>`, lo que podría hacerte creer que no bloquea. Pero `async` solo permite usar `await` dentro del cuerpo — **no mueve el código a otro hilo**. El `for` loop sigue ejecutándose síncronamente en el main isolate.
:::

### Botón 2: Run Isolate Example (✅ No bloquea la UI)

```dart
ElevatedButton(
  onPressed: () async {
    // 1️⃣ Crear un ReceivePort para recibir mensajes
    final receivePort = ReceivePort();

    // 2️⃣ Crear un isolate nuevo y pasarle nuestro SendPort
    await Isolate.spawn(
      IsolateExample.heavyProcess,  // La función a ejecutar
      receivePort.sendPort,         // Canal de comunicación
    );

    // 3️⃣ Escuchar los mensajes que lleguen del isolate
    receivePort.listen((message) {
      print("Received message from isolate: $message");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Isolate result: $message")),
      );
    });

    print("Isolate spawned and listening for messages.");
  },
  child: const Text('Run Isolate Example'),
),
```

#### ¿Qué sucede paso a paso?

```
1. Tap en "Run Isolate Example"
2. Se crea un ReceivePort (buzón de mensajes)
3. Se crea un NUEVO isolate con Isolate.spawn()
4. El nuevo isolate ejecuta IsolateExample.heavyProcess()
5. 🐱 El GIF SIGUE animándose (el main isolate está libre)
6. ✅ Los botones siguen respondiendo
7. ✅ La UI es fluida a 60fps
8. ... (el isolate trabaja en segundo plano)
9. El isolate termina y envía el resultado por sendPort
10. El receivePort recibe el mensaje
11. Se muestra el SnackBar con el resultado
```

## 📂 El trabajo pesado: `isolate_example.dart`

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
    // 📨 Enviar el resultado de vuelta al main isolate
    sendPort.send(result);
    print("El cómputo pesado ha terminado. Isolate");
  }
}
```

### Requisitos de la función del isolate

La función que pasamos a `Isolate.spawn()` debe cumplir ciertas reglas:

| Regla | ¿Por qué? |
|---|---|
| Debe ser **top-level** o **static** | Los isolates no comparten memoria, no pueden acceder a instancias |
| Recibe exactamente **un argumento** | El protocolo de `Isolate.spawn()` lo requiere |
| Solo puede enviar tipos **serializables** | Los datos se copian, no se comparten |

### Tipos que puedes enviar entre isolates

| ✅ Permitido | ❌ No permitido |
|---|---|
| `int`, `double`, `String`, `bool` | Closures / funciones anónimas |
| `List`, `Map` (con valores serializables) | Objetos con referencias nativas |
| `SendPort` | `BuildContext`, `Widget` |
| `Uint8List`, `Float64List` | Sockets, file handles |
| `null` | `Stream`, `StreamController` |

## 🔄 Diagrama de Comunicación

```
┌──────────────────────┐          ┌──────────────────────┐
│     MAIN ISOLATE     │          │    NUEVO ISOLATE     │
│                      │          │                      │
│ 1. Crear ReceivePort │          │                      │
│ 2. Isolate.spawn() ──┼─────────►│ 3. Ejecutar función  │
│    (pasa sendPort)   │          │    heavyProcess()    │
│                      │          │                      │
│                      │          │ 4. for-loop (pesado) │
│ 🐱 GIF animándose   │          │    ... procesando    │
│ ✅ UI respondiendo   │          │                      │
│                      │          │ 5. sendPort.send()   │
│ 6. receivePort ◄─────┼──────────┤    (envía resultado) │
│    .listen()         │          │                      │
│ 7. Mostrar SnackBar  │          │ 8. Isolate termina   │
└──────────────────────┘          └──────────────────────┘
```

## 🧪 Pruébalo tú mismo

1. Clona el repositorio y navega al proyecto:
   ```bash
   git clone https://github.com/weincoder/flutter-avanzado.git
   cd flutter-avanzado/isolates/intro_isolates
   ```

2. Instala dependencias y ejecuta:
   ```bash
   flutter pub get
   flutter run
   ```

3. **Experimento 1**: Toca "Heavy Process" y observa cómo el GIF se congela 🥶
4. **Experimento 2**: Toca "Run Isolate Example" y observa cómo el GIF sigue animándose 🐱

## 📝 Resumen

| Concepto | En el proyecto |
|---|---|
| **Problema** | `heavyProcess()` en `home_page.dart` bloquea el main isolate |
| **Solución** | `IsolateExample.heavyProcess()` corre en un isolate separado |
| **Comunicación** | `ReceivePort` (main) ← `SendPort` (isolate) |
| **Indicador visual** | El GIF del gato muestra si la UI está congelada |
| **API usada** | `Isolate.spawn()` — crea un isolate nuevo |

## ⚡ Cuándo usar `Isolate.spawn()` vs `compute()`

| | `Isolate.spawn()` | `compute()` |
|---|---|---|
| **Control** | Total (tú manejas ports) | Automático |
| **Comunicación** | Bidireccional posible | Solo retorno de valor |
| **Complejidad** | Media | Baja |
| **Caso de uso** | Isolates de larga vida, múltiples mensajes | Operación única, fire-and-forget |
| **Nuestro ejemplo** | ✅ Lo que usamos | Alternativa simplificada |

:::tip
`compute()` es una abstracción de Flutter que internamente crea un `Isolate.spawn()`, ejecuta la función, recibe el resultado y cierra el isolate. Es más simple pero menos flexible.
:::

## 🗺 Siguiente: [Isolates Avanzado](./avanzado)

En la siguiente sección veremos cómo evolucionar el proyecto `intro_isolates` con:
- Comunicación **bidireccional** entre isolates
- **Pool de isolates** para múltiples tareas
- **Streams** para enviar progreso en tiempo real
- Manejo de errores y mejores prácticas
