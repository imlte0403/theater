import 'package:flutter/material.dart';
import 'package:theater/screens/home.dart' show EnhancedHomeScreen;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const EnhancedHomeScreen(),
    );
  }
}
