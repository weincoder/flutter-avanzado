import 'dart:isolate';

class IsolateExample {
  // This class serves as a placeholder for isolate-related functionality.
  // You can add methods and properties to handle isolate operations here.

  void run() {
    // Example method to demonstrate isolate functionality
    print("Running isolate example...");
  }

  static heavyProcess(SendPort sendPort) {
    // Simulate a heavy process
    print("Comienza el cómputo pesado... Isolate");
    double result = 0.0;
    for (int i = 0; i < 1000000000; i++) {
      // Simulación de tarea pesada
      result += i; // Operación ficticia
    }
    sendPort.send(result);
    print("El cómputo pesado ha terminado. Isolate");
  }
}
