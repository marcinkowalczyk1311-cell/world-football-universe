import 'package:flutter/foundation.dart';

import 'competition_manager.dart';
import 'game_event.dart';
import 'match.dart';
import 'match_engine.dart';
import 'match_history.dart';
import 'fifa_ranking.dart';
import 'tournament_manager.dart';
import '../models/competition_type.dart';

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
    complete();
  }

  void complete({int? homeGoals, int? awayGoals}) {
    if (match.isPlayed) {
      return;
    }

    log();

    final matchEngine = MatchEngine();
    matchEngine.play(match, homeGoals: homeGoals, awayGoals: awayGoals);

    if (match.competition.type != CompetitionType.friendly) {
      FifaRanking.updateAfterMatch(
        home: match.homeTeam,
        away: match.awayTeam,
        homeGoals: match.homeGoals!,
        awayGoals: match.awayGoals!,
        importance: match.competition.type == CompetitionType.worldCup
            ? 40
            : 25,
      );
    }

    // Zapisz rozegrany mecz do historii
    MatchHistory.add(match);

    // Powiadom system rozgrywek o zakończeniu meczu
    CompetitionManager().onMatchFinished(match);
    TournamentManager.instance.onMatchFinished(match);

    debugPrint("⚽ Mecz zakończony");
    debugPrint(
      "${match.homeTeam.name} ${match.homeGoals} : ${match.awayGoals} ${match.awayTeam.name}",
    );
  }
}
