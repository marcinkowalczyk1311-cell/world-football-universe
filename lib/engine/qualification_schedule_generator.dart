import '../models/competition.dart';
import '../models/competition_type.dart';
import '../models/national_team.dart';
import '../models/qualification_group.dart';
import '../models/tournament.dart';
import 'match.dart';

class QualificationScheduleGenerator {
  List<Match> generate(
    QualificationGroup group, {
    required DateTime startDate,
    Competition? competition,
    String? tournamentEditionId,
  }) {
    final matches = <Match>[];
    final rotation = <NationalTeam?>[
      ...group.teams,
      if (group.teams.length.isOdd) null,
    ];

    competition ??= const Competition(
      id: 'wcq',
      name: 'Kwalifikacje do Mistrzostw Świata',
      shortName: 'MŚ EL',
      type: CompetitionType.worldCupQualifiers,
    );

    final roundsPerLeg = rotation.length - 1;
    final matchesPerRound = rotation.length ~/ 2;

    for (var leg = 0; leg < 2; leg++) {
      for (var round = 0; round < roundsPerLeg; round++) {
        final date = startDate.add(
          Duration(days: 7 * (leg * roundsPerLeg + round)),
        );

        for (var pairing = 0; pairing < matchesPerRound; pairing++) {
          final first = rotation[pairing];
          final second = rotation[rotation.length - 1 - pairing];

          if (first == null || second == null) {
            continue;
          }

          matches.add(
            Match(
              homeTeam: leg == 0 ? first : second,
              awayTeam: leg == 0 ? second : first,
              date: date,
              competition: competition,
              tournamentEditionId: tournamentEditionId,
              tournamentStage: TournamentStage.qualification,
            ),
          );
        }

        final last = rotation.removeLast();
        rotation.insert(1, last);
      }
    }

    return matches;
  }

  static void validate(QualificationGroup group, List<Match> fixtures) {
    final ids = group.teams.map((team) => team.id).toSet();
    final expected = group.teams.length * (group.teams.length - 1);
    if (fixtures.length != expected) {
      throw StateError('Incomplete fixture list for group ${group.name}.');
    }
    if (fixtures.any(
      (match) =>
          !ids.contains(match.homeTeam.id) ||
          !ids.contains(match.awayTeam.id) ||
          match.homeTeam.id == match.awayTeam.id,
    )) {
      throw StateError('A fixture contains a team outside its group.');
    }
    final pairings = fixtures
        .map((match) => '${match.homeTeam.id}:${match.awayTeam.id}')
        .toSet();
    if (pairings.length != expected) {
      throw StateError('Duplicate or missing home/away fixtures.');
    }
  }
}
