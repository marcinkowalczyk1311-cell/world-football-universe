import '../models/continent_type.dart';
import '../models/qualification_group.dart';
import '../models/national_team.dart';

class QualificationGenerator {
  static const int maxGroupSize = 10;

  List<QualificationGroup> generate({
    required List<NationalTeam> teams,
    required ContinentType confederation,
    required NationalTeam playerTeam,
  }) {
    if (playerTeam.continent != confederation) {
      throw ArgumentError('The player team must belong to the confederation.');
    }

    final confederationTeams =
        teams.where((team) => team.continent == confederation).toList()
          ..sort((a, b) => a.fifaRanking.compareTo(b.fifaRanking));

    if (!confederationTeams.any((team) => team.id == playerTeam.id)) {
      throw ArgumentError('The player team is missing from the team database.');
    }

    final groupCount = (confederationTeams.length / maxGroupSize).ceil();
    final groupTeams = List.generate(groupCount, (_) => <NationalTeam>[]);

    // Seed teams across evenly-sized groups. This works for every database
    // confederation without maintaining a second, demo-era team list.
    for (var index = 0; index < confederationTeams.length; index++) {
      groupTeams[index % groupCount].add(confederationTeams[index]);
    }

    final playerGroupIndex = groupTeams.indexWhere(
      (group) => group.any((team) => team.id == playerTeam.id),
    );
    final orderedGroups = [
      groupTeams[playerGroupIndex],
      for (var index = 0; index < groupTeams.length; index++)
        if (index != playerGroupIndex) groupTeams[index],
    ];

    return List.generate(
      orderedGroups.length,
      (index) => QualificationGroup(
        name: String.fromCharCode(65 + index),
        teams: List.unmodifiable(orderedGroups[index]),
      ),
      growable: false,
    );
  }
}
