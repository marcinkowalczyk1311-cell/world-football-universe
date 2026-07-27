import '../models/continent_type.dart';
import '../models/national_team.dart';
import '../models/qualification_group.dart';
import '../models/qualification_state.dart';

class GameData {
  String? selectedContinent;

  String? selectedCountry;

  NationalTeam? selectedTeam;

  ContinentType? selectedConfederation;

  QualificationState? qualification;

  List<QualificationGroup> get qualificationGroups =>
      qualification?.groups ?? const [];

  List<NationalTeam> get qualificationTeams => qualification?.teams ?? const [];

  void initializeCareer(NationalTeam team) {
    selectedTeam = team;
    selectedCountry = team.name;
    selectedConfederation = team.continent;
    selectedContinent = team.continent.displayName;
  }
}
