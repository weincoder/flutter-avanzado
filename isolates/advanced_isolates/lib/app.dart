import 'package:flutter/material.dart';

import 'pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Isolates',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C3CE0),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C3CE0),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
