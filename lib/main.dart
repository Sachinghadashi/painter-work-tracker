// lib/main.dart
import 'package:flutter/material.dart';

import 'screens/login_page.dart';

void main() {
  runApp(const PainterWorkApp());
}

class PainterWorkApp extends StatelessWidget {
  const PainterWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painter Work Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
