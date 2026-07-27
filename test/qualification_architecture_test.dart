import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/data/national_teams.dart';
import 'package:football_simulator/data/tournaments.dart';
import 'package:football_simulator/engine/competition_qualification_generators.dart';
import 'package:football_simulator/models/continent_type.dart';

void main() {
  final worldCup = internationalTournaments.singleWhere(
    (tournament) => tournament.id == 'FIFA_WORLD_CUP',
  );

  for (final confederation in ContinentType.values) {
    test('${confederation.name} qualification is structurally valid', () {
      final eligible = allNationalTeams
          .where((team) => team.continent == confederation)
          .toList();
      final state = const WorldCupQualificationGenerator().generate(
        tournament: worldCup,
        teams: allNationalTeams,
        confederation: confederation,
        playerTeam: eligible.first,
        startDate: DateTime(2026, 9, 1),
        finalsYear: 2030,
      );

      final assigned = state.groups.expand((group) => group.teams).toList();
      expect(assigned, hasLength(eligible.length));
      expect(
        assigned.map((team) => team.id).toSet(),
        eligible.map((team) => team.id).toSet(),
      );
      expect(
        assigned.map((team) => team.id).toSet(),
        hasLength(assigned.length),
      );

      for (final group in state.groups) {
        final groupIds = group.teams.map((team) => team.id).toSet();
        final fixtures = state.fixtures
            .where(
              (match) =>
                  groupIds.contains(match.homeTeam.id) &&
                  groupIds.contains(match.awayTeam.id),
            )
            .toList();
        expect(group.teams.length, inInclusiveRange(3, 10));
        expect(
          fixtures,
          hasLength(group.teams.length * (group.teams.length - 1)),
        );
        expect(
          fixtures.every(
            (match) =>
                groupIds.contains(match.homeTeam.id) &&
                groupIds.contains(match.awayTeam.id),
          ),
          isTrue,
        );
        expect(group.advancingTeams, hasLength(group.advancingTeamCount));
        expect(
          group.advancingTeams.every((team) => groupIds.contains(team.id)),
          isTrue,
        );
      }
    });
  }

  test('every qualifying tournament has its own registered generator', () {
    final qualifying = internationalTournaments.where(
      (tournament) => tournament.hasQualification,
    );
    for (final tournament in qualifying) {
      expect(
        QualificationGeneratorRegistry.forTournament(
          tournament.id,
        ).tournamentId,
        tournament.id,
      );
    }
    expect(
      QualificationGeneratorRegistry.generators.values
          .map((generator) => generator.runtimeType)
          .toSet(),
      hasLength(qualifying.length),
    );
  });
}
