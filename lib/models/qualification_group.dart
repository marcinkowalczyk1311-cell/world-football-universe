import 'national_team.dart';
import 'qualification_table_row.dart';

class QualificationGroup {
  final String name;

  final List<NationalTeam> teams;
  final int advancingTeamCount;

  late final List<QualificationTableRow> table;

  QualificationGroup({
    required this.name,
    required this.teams,
    required this.advancingTeamCount,
  }) {
    if (teams.length < 2) {
      throw ArgumentError('A qualification group needs at least two teams.');
    }
    if (teams.map((team) => team.id).toSet().length != teams.length) {
      throw ArgumentError(
        'A qualification group cannot contain duplicate teams.',
      );
    }
    if (advancingTeamCount < 1 || advancingTeamCount >= teams.length) {
      throw ArgumentError('Invalid number of advancing teams.');
    }
    table = teams.map((team) => QualificationTableRow(team: team)).toList();
  }

  List<NationalTeam> get advancingTeams =>
      List.unmodifiable(table.take(advancingTeamCount).map((row) => row.team));
}
