import 'national_team.dart';

class QualificationTableRow {
  final NationalTeam team;

  int played;
  int wins;
  int draws;
  int losses;

  int goalsFor;
  int goalsAgainst;

  int points;

  QualificationTableRow({
    required this.team,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;
}