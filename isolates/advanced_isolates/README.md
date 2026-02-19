# 🧶 Advanced Isolates

Proyecto Flutter que implementa los **6 patrones avanzados de isolates** documentados en el curso [Flutter Avanzado](https://weincoder.github.io/flutter-avanzado/).

> 📖 **Documentación completa**: [Isolates Avanzado](https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado)

## 🎯 ¿Qué demuestra este proyecto?

Cada patrón tiene su propia pantalla interactiva con un **GIF de gato** 🐱 como indicador visual: si se congela, la UI está bloqueada.

| # | Patrón | Archivo | Página |
|---|---|---|---|
| 1 | 🔄 Comunicación Bidireccional | `isolates/bidirectional_isolate.dart` | `pages/bidirectional_page.dart` |
| 2 | 🔁 Worker Persistente | `isolates/persistent_worker.dart` | `pages/persistent_page.dart` |
| 3 | 📊 Progreso en Tiempo Real | `isolates/progress_isolate.dart` | `pages/progress_page.dart` |
| 4 | 🏊 Pool de Isolates | `isolates/isolate_pool.dart` | `pages/pool_page.dart` |
| 5 | 🛡 Error Handling | `isolates/safe_isolate.dart` | `pages/error_handling_page.dart` |
| 6 | ⚡ compute() Simplificado | `isolates/compute_example.dart` | `pages/compute_page.dart` |

## 📂 Estructura

```
lib/
├── main.dart                          # Punto de entrada
├── app.dart                           # MaterialApp con tema Weincode
├── isolates/                          # 🧠 Lógica de los patrones
│   ├── bidirectional_isolate.dart     # Handshake bidireccional
│   ├── persistent_worker.dart         # Worker de larga vida
│   ├── progress_isolate.dart          # Stream de progreso
│   ├── isolate_pool.dart              # Pool round-robin
│   ├── safe_isolate.dart              # Error handling con Completer
│   └── compute_example.dart           # Abstracción compute()
├── pages/                             # 📱 UI de cada demo
│   ├── home_page.dart                 # Lista de patrones
│   ├── bidirectional_page.dart
│   ├── persistent_page.dart
│   ├── progress_page.dart
│   ├── pool_page.dart
│   ├── error_handling_page.dart
│   └── compute_page.dart
└── widgets/                           # 🧩 Widgets reutilizables
    ├── cat_gif.dart                   # GIF indicador de bloqueo
    └── result_card.dart               # Tarjeta de resultado
```

## 🚀 Cómo ejecutar

```bash
# Clonar el repositorio
git clone https://github.com/weincoder/flutter-avanzado.git
cd flutter-avanzado/isolates/advanced_isolates

# Instalar dependencias
flutter pub get

# Ejecutar
flutter run
```

## 🧪 Qué probar en cada demo

### 🔄 Bidireccional
- Observa cómo **2 tareas** se envían al **mismo** isolate secuencialmente
- El handshake intercambia `SendPort`s en ambas direcciones

### 🔁 Worker Persistente
- El worker se inicia al entrar a la página
- Puedes enviar **múltiples tareas** sin recrear el isolate
- Se destruye al salir (verifica en los logs)

### 📊 Progreso
- La barra de progreso se actualiza **cada 1%**
- El isolate envía valores 0.0→1.0 por `SendPort`
- Observa el GIF animándose mientras el progreso avanza

### 🏊 Pool
- Se crean N workers (cores - 1)
- 4 tareas pesadas se ejecutan **en paralelo**
- Mide el tiempo total vs ejecutarlas secuencialmente

### 🛡 Error Handling
- "Éxito" ejecuta normalmente
- "Forzar Error" pasa -1 iteraciones → `throw` en el isolate
- El error es capturado con `Isolate.spawn(onError:)` + `Completer`

### ⚡ compute()
- Una sola línea: `await compute(heavyProcess, 1000000000)`
- Crea, ejecuta y destruye el isolate automáticamente
- Ideal para operaciones únicas

## 📚 Relación con la documentación

Este proyecto es el **compañero práctico** del módulo de Isolates:

| Doc | Proyecto |
|---|---|
| [Introducción](https://weincoder.github.io/flutter-avanzado/docs/isolates/introduccion) | `intro_isolates` (proyecto hermano) |
| [Básico](https://weincoder.github.io/flutter-avanzado/docs/isolates/basico) | `intro_isolates` |
| [Avanzado](https://weincoder.github.io/flutter-avanzado/docs/isolates/avanzado) | **`advanced_isolates`** (este proyecto) |

## 🤝 Contribuir

¿Encontraste un bug o quieres agregar un patrón? ¡Abre un PR!

[![Discord](https://img.shields.io/badge/Discord-Weincode-5865F2?logo=discord&logoColor=white)](https://discord.gg/mtJWZFZE7R)
