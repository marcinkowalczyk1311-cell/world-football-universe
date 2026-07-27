import 'package:flutter/material.dart';

import '../engine/game_engine.dart';
import 'career_screen.dart';

class CareerStartScreen extends StatelessWidget {
  const CareerStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = GameEngine.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rozpoczęcie kariery"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            engine.startGame();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const CareerScreen(),
              ),
            );
          },
          child: const Text("Rozpocznij karierę"),
        ),
      ),
    );
  }
}