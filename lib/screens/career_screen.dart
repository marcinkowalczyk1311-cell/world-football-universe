import 'package:flutter/material.dart';

import '../engine/game_engine.dart';
import '../engine/match_event.dart';
import '../widgets/career_header.dart';
import '../widgets/match_history_card.dart';
import '../widgets/next_match_card.dart';
import '../widgets/statistics_card.dart';
import 'fifa_ranking_screen.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  final engine = GameEngine.instance;

  @override
  Widget build(BuildContext context) {
    final MatchEvent? nextMatch = engine.eventManager.nextMatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text("World Football Universe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            CareerHeader(
              country: engine.data.selectedCountry ?? "-",
              date: engine.clock.currentDate,
            ),

            const SizedBox(height: 20),

            NextMatchCard(
              nextMatch: nextMatch,
            ),

            const SizedBox(height: 20),

            StatisticsCard(
              teamName: engine.data.selectedCountry ?? "",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.public),
                label: const Text(
                  "Ranking FIFA",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FifaRankingScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Historia meczów",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const MatchHistoryCard(),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    engine.nextDay();
                  });
                },
                icon: const Icon(Icons.skip_next),
                label: const Text(
                  "Następny dzień",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    engine.skipToNextMatch();
                  });
                },
                icon: const Icon(Icons.sports_soccer),
                label: const Text(
                  "Do następnego meczu",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}