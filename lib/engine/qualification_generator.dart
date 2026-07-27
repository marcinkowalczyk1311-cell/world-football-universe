import 'dart:math';

import '../models/continent_type.dart';
import '../models/qualification_group.dart';
import '../models/national_team.dart';

class QualificationGenerator {
  List<QualificationGroup> generateEuropeanGroups(
      List<NationalTeam> teams,
      ) {
    final europeanTeams = teams
        .where((team) => team.continent == ContinentType.europe)
        .toList();

    europeanTeams.shuffle(Random());

    final List<QualificationGroup> groups = [];

    int groupIndex = 0;

    while (europeanTeams.isNotEmpty) {
      final List<NationalTeam> groupTeams = [];

      while (groupTeams.length < 4 && europeanTeams.isNotEmpty) {
        groupTeams.add(europeanTeams.removeAt(0));
      }

      groups.add(
        QualificationGroup(
          name: String.fromCharCode(65 + groupIndex),
          teams: groupTeams,
        ),
      );

      groupIndex++;
    }

    return groups;
  }
}