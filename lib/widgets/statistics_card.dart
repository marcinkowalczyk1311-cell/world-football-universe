import 'package:flutter/material.dart';

import '../engine/team_statistics.dart';

class StatisticsCard extends StatelessWidget {
  final String teamName;

  const StatisticsCard({
    super.key,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    final statistics = TeamStatistics(teamName);
    statistics.calculate();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "📊 Statystyki",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Mecze"),
                Text("${statistics.matches}"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Wygrane"),
                Text("${statistics.wins}"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Remisy"),
                Text("${statistics.draws}"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Porażki"),
                Text("${statistics.losses}"),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bramki"),
                Text(
                  "${statistics.goalsFor} : ${statistics.goalsAgainst}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}