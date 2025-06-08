import 'package:flutter/material.dart';

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
            const Text(
              'Welcome to the Isolates Intro!',
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder for future functionality
              },
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder for future functionality
              },
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> heavyProcess() async {
    // Simulate a heavy process
    print("Comienza el cómputo pesado...");
    double result = 0.0;
    for (int i = 0; i < 1000000000; i++) {
      // Simulación de tarea pesada
      result += i; // Operación ficticia
    }
    print("El cómputo pesado ha terminado.");
    return result;
  }
}
