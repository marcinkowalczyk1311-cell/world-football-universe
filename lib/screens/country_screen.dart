import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../engine/game_engine.dart';
import '../models/continent.dart';
import '../models/country.dart';
import 'career_start_screen.dart';

class CountryScreen extends StatelessWidget {
  final Continent continent;

  const CountryScreen({
    super.key,
    required this.continent,
  });

  @override
  Widget build(BuildContext context) {
    final List<Country> continentCountries =
    countries.where((c) => c.continent == continent.name).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B3D2E),
      appBar: AppBar(
        title: Text(continent.name),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B6E4F),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: continentCountries.length,
        itemBuilder: (context, index) {
          final country = continentCountries[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final engine = GameEngine.instance;

                  engine.data.selectedContinent = continent.name;
                  engine.data.selectedCountry = country.name;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareerStartScreen(),
                    ),
                  );
                },
                child: Text(
                  "${country.flag} ${country.name}",
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