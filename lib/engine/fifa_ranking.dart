import 'dart:math';
import '../models/national_team.dart';

class FifaRanking {
  static final Map<String, double> _points = {};
  static final Map<String, NationalTeam> _teams = {};

  static void initialize(List<NationalTeam> teams) {
    _points.clear();
    _teams.clear();
    for (final team in teams) {
      _teams[team.name] = team;
      _points[team.name] = 2100 - (team.fifaRanking - 1) * 4.5;
    }
    _refreshPositions();
  }

  static double getPoints(String team) => _points[team] ?? 0;
  static void setPoints(String team, num points) {
    _points[team] = points.toDouble();
    _refreshPositions();
  }

  static List<MapEntry<String, double>> getRanking() =>
      _points.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  static void updateAfterMatch({
    required NationalTeam home,
    required NationalTeam away,
    required int homeGoals,
    required int awayGoals,
    double importance = 25,
  }) {
    if (!_points.containsKey(home.name) || !_points.containsKey(away.name)) {
      return;
    }
    final hp = _points[home.name]!, ap = _points[away.name]!;
    final expected = 1 / (1 + pow(10, (ap - hp) / 600));
    final actual = homeGoals > awayGoals
        ? 1.0
        : homeGoals == awayGoals
        ? .5
        : 0.0;
    final margin = (homeGoals - awayGoals).abs();
    final change =
        importance *
        (margin <= 1 ? 1 : 1 + (margin - 1) * .12) *
        (actual - expected);
    _points[home.name] = hp + change;
    _points[away.name] = ap - change;
    _refreshPositions();
  }

  static void _refreshPositions() {
    final ranking = getRanking();
    for (var i = 0; i < ranking.length; i++) {
      _teams[ranking[i].key]?.fifaRanking = i + 1;
    }
  }
}
