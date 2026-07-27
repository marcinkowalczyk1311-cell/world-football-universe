import '../data/competitions.dart';
import '../data/national_teams.dart';
import '../models/competition.dart';
import '../models/national_team.dart';

class World {
  final List<NationalTeam> nationalTeams = [];
  final List<Competition> competitions = [];

  void initialize() {
    nationalTeams.clear();
    competitions.clear();

    nationalTeams.addAll(allNationalTeams);
    competitions.addAll(allCompetitions);
  }

  NationalTeam getNationalTeam(String name) {
    return nationalTeams.firstWhere(
          (team) => team.name == name,
    );
  }

  Competition getCompetition(String id) {
    return competitions.firstWhere(
          (competition) => competition.id == id,
    );
  }
}