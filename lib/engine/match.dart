import '../models/competition.dart';
import '../models/national_team.dart';
import '../models/tournament.dart';

class Match {
  final NationalTeam homeTeam;
  final NationalTeam awayTeam;

  final DateTime date;

  final Competition competition;
  final String? tournamentEditionId;
  final TournamentStage? tournamentStage;
  final bool isTournamentFinal;

  int? homeGoals;
  int? awayGoals;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.competition,
    this.tournamentEditionId,
    this.tournamentStage,
    this.isTournamentFinal = false,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;
}
