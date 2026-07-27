import 'package:flutter/material.dart';
import 'new_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D2E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.public,
                  size: 90,
                  color: Colors.amber,
                ),

                const SizedBox(height: 15),

                const Icon(
                  Icons.sports_soccer,
                  size: 70,
                  color: Colors.white,
                ),

                const SizedBox(height: 30),

                const Text(
                  "WORLD\nFOOTBALL\nUNIVERSE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 60),

                _menuButton(
                  context,
                  "▶ NOWA GRA",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewGameScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                _menuButton(
                  context,
                  "📂 WCZYTAJ GRĘ",
                      () {},
                ),

                const SizedBox(height: 15),

                _menuButton(
                  context,
                  "⚙ USTAWIENIA",
                      () {},
                ),

                const SizedBox(height: 60),

                const Text(
                  "WFU Studios",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _menuButton(
      BuildContext context,
      String text,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: 280,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}