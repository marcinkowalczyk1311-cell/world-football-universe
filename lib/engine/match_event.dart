import 'package:flutter/foundation.dart';

import 'competition_manager.dart';
import 'game_event.dart';
import 'match.dart';
import 'match_engine.dart';
import 'match_history.dart';

class MatchEvent extends GameEvent {
  final Match match;

  MatchEvent({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required this.match,
  });

  @override
  void execute() {
    log();

    final matchEngine = MatchEngine();
    matchEngine.play(match);

    // Zapisz rozegrany mecz do historii
    MatchHistory.add(match);

    // Powiadom system rozgrywek o zakończeniu meczu
    CompetitionManager().onMatchFinished(match);

    debugPrint("⚽ Mecz zakończony");
    debugPrint(
      "${match.homeTeam.name} ${match.homeGoals} : ${match.awayGoals} ${match.awayTeam.name}",
    );
  }
}