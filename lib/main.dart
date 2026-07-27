import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WorldFootballUniverseApp());
}

class WorldFootballUniverseApp extends StatelessWidget {
  const WorldFootballUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Football Universe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}