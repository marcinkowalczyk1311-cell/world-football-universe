import 'package:flutter/material.dart';

import '../engine/game_engine.dart';

class TournamentHub extends StatelessWidget {
  const TournamentHub({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = GameEngine.instance;
    final current = engine.clock.currentDate;
    final active = engine.internationalCalendar.activeWindow(
      current,
      confederation: engine.data.selectedConfederation,
    );
    final history = engine.tournamentManager.history;
    final messages = engine.tournamentManager.timeline
        .where((item) => !item.date.isAfter(current))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          active == null
              ? 'No international window active'
              : active.isFriendly
              ? 'International friendlies'
              : '${active.tournament!.name} · ${active.stage!.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Text('World timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (messages.isEmpty)
          const Text('Competition news will appear here.')
        else
          ...messages
              .take(30)
              .map(
                (item) => ListTile(
                  leading: const Icon(Icons.public),
                  title: Text(item.message),
                  subtitle: Text(item.date.toString().split(' ').first),
                ),
              ),
        const Divider(height: 36),
        Text('Past champions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Text(
            'Champions will be stored here forever after finals are played.',
          )
        else
          ...history.map(
            (item) => ListTile(
              leading: Text(item.winner.flag),
              title: Text('${item.year} · ${item.winner.name}'),
              subtitle: Text(item.tournamentName),
            ),
          ),
      ],
    );
  }
}
