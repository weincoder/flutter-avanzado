---
sidebar_position: 3
---

# Isolates Avanzado

En esta sección aprenderás patrones avanzados de isolates para comunicación bidireccional y manejo de isolates de larga duración.

## Creación Manual de Isolates

Para más control, puedes crear isolates manualmente usando `Isolate.spawn()`:

```dart
import 'dart:isolate';

void main() async {
  final receivePort = ReceivePort();
  
  // Crear isolate
  await Isolate.spawn(
    isolateEntry,
    receivePort.sendPort,
  );
  
  // Escuchar mensajes del isolate
  receivePort.listen((message) {
    print('Mensaje recibido: $message');
  });
}

void isolateEntry(SendPort sendPort) {
  sendPort.send('¡Hola desde el isolate!');
}
```

## Comunicación Bidireccional

Para comunicación bidireccional, ambos lados necesitan puertos:

```dart
import 'dart:isolate';

void main() async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(
    isolateEntry,
    receivePort.sendPort,
  );
  
  // El isolate nos enviará su SendPort
  final isolateSendPort = await receivePort.first as SendPort;
  
  // Ahora podemos enviar y recibir
  final responsePort = ReceivePort();
  isolateSendPort.send(['COMPUTE', 5, responsePort.sendPort]);
  
  // Recibir respuesta
  final result = await responsePort.first;
  print('Resultado: $result');
}

void isolateEntry(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort);
  
  port.listen((message) {
    if (message is List) {
      final command = message[0];
      final value = message[1];
      final responseSendPort = message[2] as SendPort;
      
      if (command == 'COMPUTE') {
        final result = fibonacci(value);
        responseSendPort.send(result);
      }
    }
  });
}

int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}
```

## Pool de Isolates

Para operaciones múltiples, es más eficiente reutilizar isolates:

```dart
class IsolatePool {
  final int poolSize;
  late List<SendPort> _sendPorts;
  int _currentIndex = 0;

  IsolatePool({this.poolSize = 4});

  Future<void> initialize() async {
    _sendPorts = [];
    
    for (int i = 0; i < poolSize; i++) {
      final receivePort = ReceivePort();
      
      await Isolate.spawn(
        _poolWorker,
        receivePort.sendPort,
      );
      
      final sendPort = await receivePort.first as SendPort;
      _sendPorts.add(sendPort);
    }
  }

  Future<dynamic> execute(dynamic task) async {
    final sendPort = _sendPorts[_currentIndex];
    _currentIndex = (_currentIndex + 1) % poolSize;
    
    final responsePort = ReceivePort();
    sendPort.send([task, responsePort.sendPort]);
    
    return await responsePort.first;
  }

  static void _poolWorker(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);
    
    port.listen((message) {
      final task = message[0];
      final responseSendPort = message[1] as SendPort;
      
      // Ejecutar tarea
      final result = _executeTask(task);
      responseSendPort.send(result);
    });
  }

  static dynamic _executeTask(dynamic task) {
    // Lógica de ejecución
    return task;
  }
}

// Uso
void main() async {
  final pool = IsolatePool(poolSize: 4);
  await pool.initialize();
  
  // Ejecutar múltiples tareas
  final futures = [1, 2, 3, 4, 5].map((i) => pool.execute(i));
  final results = await Future.wait(futures);
  
  print(results);
}
```

## Stream en Isolates

Para comunicación de múltiples mensajes, usa Streams:

```dart
import 'dart:isolate';
import 'dart:async';

class IsolateStream {
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  Future<void> start() async {
    _receivePort = ReceivePort();
    
    await Isolate.spawn(
      _streamWorker,
      _receivePort.sendPort,
    );
    
    _sendPort = await _receivePort.first;
  }

  Stream<int> getCounterStream(int start, int end) {
    final controller = StreamController<int>();
    
    final responsePort = ReceivePort();
    _sendPort.send(['STREAM', start, end, responsePort.sendPort]);
    
    responsePort.listen((data) {
      if (data == 'DONE') {
        controller.close();
      } else {
        controller.add(data as int);
      }
    });
    
    return controller.stream;
  }

  static void _streamWorker(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);
    
    port.listen((message) {
      if (message is List && message[0] == 'STREAM') {
        final start = message[1] as int;
        final end = message[2] as int;
        final responseSendPort = message[3] as SendPort;
        
        for (int i = start; i < end; i++) {
          responseSendPort.send(i);
          sleep(Duration(milliseconds: 100));
        }
        
        responseSendPort.send('DONE');
      }
    });
  }
}

// Uso en Flutter
class CounterStreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isolateStream = IsolateStream();
    
    return FutureBuilder(
      future: isolateStream.start(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<int>(
            stream: isolateStream.getCounterStream(0, 100),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text('Contador: ${snapshot.data}');
              }
              return CircularProgressIndicator();
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## Error Handling

Siempre maneja posibles errores:

```dart
try {
  final result = await compute(operacionPesada, data);
} on Exception catch (e) {
  print('Error: $e');
  // Mostrar error al usuario
} finally {
  // Limpiar recursos
}
```

## Performance Tips

1. **Reutiliza isolates** cuando sea posible
2. **Evita pasar objetos grandes** entre isolates
3. **Usa `compute()` para operaciones simples** y únicas
4. **Crea un pool** para múltiples operaciones concurrentes
5. **Monitorea el número de isolates activos**

## Debugging de Isolates

```dart
// Verificar isolate actual
print('ID del isolate: ${Isolate.current.debugName}');

// Pausar/reanudar isolates (solo en debug)
await isolate.pause();
await isolate.resume(capabilities);
```

## Cuándo No Usar Isolates

❌ No uses isolates para:
- Operaciones muy rápidas (overhead > beneficio)
- UI updates frecuentes
- Datos que cambian constantemente
- Comunicación simple (usa Streams/BLoC en su lugar)
