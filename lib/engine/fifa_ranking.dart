import '../models/national_team.dart';

class FifaRanking {
  static final Map<String, int> _points = {};

  static void initialize(List<NationalTeam> teams) {
    _points.clear();

    for (final team in teams) {
      _points[team.name] = team.fifaRanking;
    }
  }

  static int getPoints(String team) {
    return _points[team] ?? 0;
  }

  static void setPoints(String team, int points) {
    _points[team] = points;
  }

  static List<MapEntry<String, int>> getRanking() {
    final ranking = _points.entries.toList();

    ranking.sort((a, b) => b.value.compareTo(a.value));

    return ranking;
  }
}