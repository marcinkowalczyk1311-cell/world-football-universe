import 'package:flutter/material.dart';

import '../engine/match_event.dart';

class NextMatchCard extends StatelessWidget {
  final MatchEvent? nextMatch;

  const NextMatchCard({
    super.key,
    required this.nextMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Następny mecz",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (nextMatch == null)
              const Text(
                "Brak zaplanowanych meczów",
                style: TextStyle(fontSize: 18),
              )
            else ...[
              Text(
                nextMatch!.match.homeTeam.name,
                style: const TextStyle(fontSize: 18),
              ),
              const Text(
                "vs",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                nextMatch!.match.awayTeam.name,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                nextMatch!.date.toString().split(' ').first,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}