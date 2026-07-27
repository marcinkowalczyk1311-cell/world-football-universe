import 'package:flutter/material.dart';

import '../engine/fifa_ranking.dart';

class FifaRankingScreen extends StatelessWidget {
  const FifaRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ranking = FifaRanking.getRanking();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ranking FIFA"),
      ),
      body: ListView.builder(
        itemCount: ranking.length,
        itemBuilder: (context, index) {
          final team = ranking[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text("${index + 1}"),
            ),
            title: Text(team.key),
            trailing: Text(
              "${team.value}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}