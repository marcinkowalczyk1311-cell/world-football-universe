import '../models/competition.dart';
import '../models/competition_type.dart';
import '../models/qualification_group.dart';
import 'match.dart';

class QualificationScheduleGenerator {
  List<Match> generate(QualificationGroup group) {
    final List<Match> matches = [];

    final teams = group.teams;

    const competition = Competition(
      id: 'wcq',
      name: 'Kwalifikacje do Mistrzostw Świata',
      shortName: 'MŚ EL',
      type: CompetitionType.worldCupQualifiers,
    );

    for (int i = 0; i < teams.length; i++) {
      for (int j = i + 1; j < teams.length; j++) {
        // Pierwszy mecz
        matches.add(
          Match(
            homeTeam: teams[i],
            awayTeam: teams[j],
            date: DateTime.now(),
            competition: competition,
          ),
        );

        // Rewanż
        matches.add(
          Match(
            homeTeam: teams[j],
            awayTeam: teams[i],
            date: DateTime.now(),
            competition: competition,
          ),
        );
      }
    }

    return matches;
  }
}