import 'package:flutter/material.dart';

import '../engine/match_history.dart';

class MatchHistoryCard extends StatelessWidget {
  const MatchHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (MatchHistory.matches.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              "Nie rozegrano jeszcze żadnego meczu.",
            ),
          ),
        ),
      );
    }

    return Column(
      children: MatchHistory.matches.reversed.map((match) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text(
              "${match.homeTeam.name} ${match.homeGoals} : ${match.awayGoals} ${match.awayTeam.name}",
            ),
            subtitle: Text(
              match.date.toString().split(' ').first,
            ),
          ),
        );
      }).toList(),
    );
  }
}