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
            const Text(
              'Welcome to the Isolates Intro!',
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/gif/cat.gif',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for future functionality
                heavyProcess().then((result) {
                  print("Heavy process completed with result: $result");
                  // You can update the UI or perform other actions with the result
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Heavy process result: $result")),
                  );
                });
              },
              child: const Text('Heavy Process'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(
                    IsolateExample.heavyProcess, receivePort.sendPort);
                receivePort.listen((message) {
                  print("Received message from isolate: $message");
                  // You can update the UI or perform other actions with the message
                  // For example, you could show a dialog or update a state variable
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Isolate result: $message")),
                  );
                });
                print("Isolate spawned and listening for messages.");
              },
              child: const Text('Run Isolate Example'),
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
