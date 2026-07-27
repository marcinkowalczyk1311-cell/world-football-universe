import 'national_team.dart';
import 'qualification_table_row.dart';

class QualificationGroup {
  final String name;

  final List<NationalTeam> teams;

  late final List<QualificationTableRow> table;

  QualificationGroup({
    required this.name,
    required this.teams,
  }) {
    table = teams
        .map(
          (team) => QualificationTableRow(team: team),
    )
        .toList();
  }
}