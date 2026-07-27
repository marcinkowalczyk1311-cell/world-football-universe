import '../models/competition.dart';
import '../models/national_team.dart';

class Match {
  final NationalTeam homeTeam;
  final NationalTeam awayTeam;

  final DateTime date;

  final Competition competition;

  int? homeGoals;
  int? awayGoals;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.competition,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;
}