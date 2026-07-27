import 'package:flutter/material.dart';

import '../data/continents.dart';
import '../models/continent.dart';
import 'country_screen.dart';

class ContinentScreen extends StatelessWidget {
  const ContinentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D2E),
      appBar: AppBar(
        title: const Text("Wybierz kontynent"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B6E4F),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: continents.length,
        itemBuilder: (context, index) {
          final Continent continent = continents[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CountryScreen(
                        continent: continent,
                      ),
                    ),
                  );
                },
                child: Text(
                  "${continent.emoji} ${continent.name}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}