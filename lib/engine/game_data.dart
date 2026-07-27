import '../models/continent_type.dart';
import '../models/national_team.dart';
import '../models/qualification_group.dart';

class GameData {
  String? selectedContinent;

  String? selectedCountry;

  NationalTeam? selectedTeam;

  ContinentType? selectedConfederation;

  List<QualificationGroup> qualificationGroups = [];

  List<NationalTeam> get qualificationTeams =>
      List.unmodifiable(qualificationGroups.expand((group) => group.teams));

  void initializeCareer(NationalTeam team) {
    selectedTeam = team;
    selectedCountry = team.name;
    selectedConfederation = team.continent;
    selectedContinent = team.continent.displayName;
  }
}
