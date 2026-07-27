import 'package:flutter/material.dart';

import 'continent_screen.dart';

class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D2E),
      appBar: AppBar(
        title: const Text("Nowa gra"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B6E4F),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SizedBox(
          width: 260,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContinentScreen(),
                ),
              );
            },
            child: const Text(
              "Kariera reprezentacji",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}