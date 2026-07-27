import 'continent_type.dart';
import 'national_team.dart';

enum TournamentStage { qualification, groupStage, knockoutStage, completed }

class TournamentDefinition {
  final String id, name, shortName;
  final ContinentType? confederation;
  final int cycleYears, firstFinalsYear, finalsTeamCount;
  final bool hasQualification;
  const TournamentDefinition({
    required this.id,
    required this.name,
    required this.shortName,
    required this.cycleYears,
    required this.firstFinalsYear,
    required this.finalsTeamCount,
    this.confederation,
    this.hasQualification = true,
  });
  bool isFinalsYear(int year) =>
      year >= firstFinalsYear && (year - firstFinalsYear) % cycleYears == 0;
}

class TournamentEdition {
  final TournamentDefinition definition;
  final int year;
  TournamentStage stage;
  final List<NationalTeam> qualifiedTeams;
  NationalTeam? champion;
  TournamentEdition({
    required this.definition,
    required this.year,
    this.stage = TournamentStage.qualification,
    List<NationalTeam>? qualifiedTeams,
    this.champion,
  }) : qualifiedTeams = qualifiedTeams ?? [];
  String get id => '${definition.id}_$year';
}

class TournamentChampion {
  final String tournamentId, tournamentName;
  final int year;
  final NationalTeam winner;
  const TournamentChampion({
    required this.tournamentId,
    required this.tournamentName,
    required this.year,
    required this.winner,
  });
}
