---
sidebar_position: 1
---

# 📍 Platform Channels y Method Channels

Los Platform Channels permiten la comunicación entre tu código Dart (Flutter) y el código nativo de la plataforma (Kotlin/Java en Android, Swift/Objective-C en iOS).

## ¿Por qué Platform Channels?

Aunque Flutter cubre la mayoría de casos de uso, a veces necesitas acceder a funcionalidades nativas:

- 📱 APIs del sistema operativo (batería, sensores, Bluetooth)
- 📷 Hardware específico (cámara avanzada, NFC)
- 🔐 Servicios nativos (Keychain, biometría)
- 📦 SDKs nativos de terceros

## Tipos de Channels

### 1. MethodChannel
Comunicación tipo request/response:

```dart
// Dart side
static const platform = MethodChannel('com.example.app/battery');

Future<int> getBatteryLevel() async {
  try {
    final int result = await platform.invokeMethod('getBatteryLevel');
    return result;
  } on PlatformException catch (e) {
    throw Exception('Error: ${e.message}');
  }
}
```

### 2. EventChannel
Para streams de datos continuos:

```dart
static const eventChannel = EventChannel('com.example.app/sensorStream');

Stream<dynamic> get sensorStream => eventChannel.receiveBroadcastStream();
```

### 3. BasicMessageChannel
Para comunicación de mensajes genéricos con codecs personalizados.

## Arquitectura

```
┌─────────────────┐         ┌─────────────────┐
│   Flutter/Dart   │ ◄─────► │  Platform Host   │
│                  │ Channel │  (iOS/Android)   │
│  MethodChannel   │ ◄─────► │  Native Code     │
└─────────────────┘         └─────────────────┘
```

## Temas que cubriremos

1. MethodChannel: Request/Response
2. EventChannel: Streams nativos
3. Implementación en Android (Kotlin)
4. Implementación en iOS (Swift)
5. Pigeon: Generación de código type-safe
6. FFI (Foreign Function Interface)
7. Testing de platform channels

## Recursos

- [Platform Channels - Flutter Docs](https://docs.flutter.dev/platform-integration/platform-channels)
- [Pigeon Package](https://pub.dev/packages/pigeon)
