import '../models/qualification_group.dart';
import '../models/qualification_table_row.dart';
import 'game_engine.dart';
import 'match.dart';

class QualificationTableManager {
  final GameEngine engine = GameEngine.instance;

  void processMatch(Match match) {
    for (final group in engine.data.qualificationGroups) {
      final containsHome =
      group.table.any((row) => row.team.name == match.homeTeam.name);
      final containsAway =
      group.table.any((row) => row.team.name == match.awayTeam.name);

      if (containsHome && containsAway) {
        addResult(
          group: group,
          homeTeam: match.homeTeam.name,
          awayTeam: match.awayTeam.name,
          homeGoals: match.homeGoals ?? 0,
          awayGoals: match.awayGoals ?? 0,
        );
        return;
      }
    }
  }

  void addResult({
    required QualificationGroup group,
    required String homeTeam,
    required String awayTeam,
    required int homeGoals,
    required int awayGoals,
  }) {
    final QualificationTableRow home = group.table.firstWhere(
          (row) => row.team.name == homeTeam,
    );

    final QualificationTableRow away = group.table.firstWhere(
          (row) => row.team.name == awayTeam,
    );

    home.played++;
    away.played++;

    home.goalsFor += homeGoals;
    home.goalsAgainst += awayGoals;

    away.goalsFor += awayGoals;
    away.goalsAgainst += homeGoals;

    if (homeGoals > awayGoals) {
      home.wins++;
      away.losses++;

      home.points += 3;
    } else if (homeGoals < awayGoals) {
      away.wins++;
      home.losses++;

      away.points += 3;
    } else {
      home.draws++;
      away.draws++;

      home.points++;
      away.points++;
    }

    group.table.sort((a, b) {
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }

      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      return b.goalsFor.compareTo(a.goalsFor);
    });
  }
}