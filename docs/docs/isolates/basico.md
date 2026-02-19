---
sidebar_position: 2
---

# Isolates Básico

En esta sección aprenderás cómo crear y usar isolates de forma básica en Flutter.

## Función `compute()`

La forma más simple de usar isolates es con la función `compute()`:

```dart
import 'dart:isolate';

// Define una función que será ejecutada en otro isolate
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// Úsala con compute()
void main() async {
  final resultado = await compute(fibonacci, 40);
  print('Resultado: $resultado');
}
```

## Ventajas de `compute()`

- ✅ Sintaxis simple
- ✅ Manejo automático de recursos
- ✅ Perfecto para operaciones únicas
- ✅ No requiere importaciones complejas

## Limitaciones

- ❌ La función debe ser de nivel superior o static
- ❌ No puedes pasar closures
- ❌ Comunicación unidireccional (no hay respuestas)

## Ejemplo Práctico: Procesamiento de Imágenes

```dart
import 'dart:typed_data';
import 'dart:isolate';

// Función para procesar imagen en otro isolate
Uint8List procesarImagen(Uint8List imageData) {
  // Simular procesamiento pesado
  List<int> result = imageData.map((byte) {
    // Aplicar filtro
    return (byte * 1.2).toInt().clamp(0, 255);
  }).toList();
  
  return Uint8List.fromList(result);
}

// En tu widget
class ImageProcessor extends StatefulWidget {
  @override
  State<ImageProcessor> createState() => _ImageProcessorState();
}

class _ImageProcessorState extends State<ImageProcessor> {
  bool _isProcessing = false;

  void _processImage(Uint8List imageData) async {
    setState(() => _isProcessing = true);
    
    try {
      final processed = await compute(procesarImagen, imageData);
      // Usar imagen procesada
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : () => _processImage(miImagen),
      child: _isProcessing ? CircularProgressIndicator() : Text('Procesar'),
    );
  }
}
```

## Reglas Importantes

1. **La función debe ser serializable**: Solo tipos primitivos y clases simples
2. **Sin contexto de aplicación**: No puedes acceder a `context`, `theme`, etc.
3. **Una sola ejecución**: `compute()` es para operaciones únicas

## Ejemplo: JSON Parsing

```dart
// Parsear JSON grande sin bloquear UI
class Usuario {
  final int id;
  final String nombre;
  final String email;

  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nombre = json['name'],
        email = json['email'];
}

// Función para parsear una lista de usuarios
List<Usuario> parseUsuarios(String jsonString) {
  final json = jsonDecode(jsonString) as List;
  return json.map((item) => Usuario.fromJson(item)).toList();
}

// Uso
void cargarUsuarios(String jsonData) async {
  final usuarios = await compute(parseUsuarios, jsonData);
  // Actualizar UI con usuarios
}
```

## Monitoreo de Progreso

Aunque `compute()` no es ideal para operaciones con progreso, puedes actualizarlo periódicamente:

```dart
Future<void> procesarMultiplesBloques() async {
  List<int> bloques = List.generate(5, (i) => i);
  
  for (int i = 0; i < bloques.length; i++) {
    await compute(procesarBloque, bloques[i]);
    
    // Actualizar progreso
    setState(() {
      progreso = (i + 1) / bloques.length;
    });
  }
}
```

## Cuándo Usar `compute()`

✅ Usa `compute()` cuando:
- Necesites ejecutar una operación pesada única
- La operación es independiente
- La función es simple y no requiere estado

❌ Usa isolates más avanzados cuando:
- Necesites comunicación bidireccional
- Quieras mantener un isolate activo
- Necesites múltiples operaciones concurrentes
