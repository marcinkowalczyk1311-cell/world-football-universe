import '../engine/match.dart';
import 'competition.dart';
import 'national_team.dart';
import 'qualification_group.dart';

class QualificationState {
  final Competition competition;
  final String editionId;
  final List<QualificationGroup> groups;
  final List<Match> fixtures;

  const QualificationState({
    required this.competition,
    required this.editionId,
    required this.groups,
    required this.fixtures,
  });

  List<NationalTeam> get teams =>
      List.unmodifiable(groups.expand((group) => group.teams));

  List<NationalTeam> get advancingTeams =>
      List.unmodifiable(groups.expand((group) => group.advancingTeams));
}
