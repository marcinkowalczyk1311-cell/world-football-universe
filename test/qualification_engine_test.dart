import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/data/national_teams.dart';
import 'package:football_simulator/engine/game_engine.dart';
import 'package:football_simulator/engine/match_event.dart';
import 'package:football_simulator/models/competition_type.dart';
import 'package:football_simulator/models/continent_type.dart';

void main() {
  final representativeTeams = <String, ContinentType>{
    'bra': ContinentType.southAmerica,
    'esp': ContinentType.europe,
    'usa': ContinentType.northAmerica,
    'jpn': ContinentType.asia,
    'aus': ContinentType.asia,
    'nga': ContinentType.africa,
    'nzl': ContinentType.oceania,
  };

  for (final entry in representativeTeams.entries) {
    test('qualification is synchronized for ${entry.key}', () {
      final engine = GameEngine.instance;
      final selected = allNationalTeams.singleWhere(
        (team) => team.id == entry.key,
      );
      engine.data.selectedCountry = selected.name;
      engine.data.selectedContinent = 'stale selection value';

      engine.startGame();

      expect(engine.data.selectedTeam, same(selected));
      expect(engine.data.selectedConfederation, entry.value);
      expect(engine.data.selectedContinent, entry.value.displayName);

      final qualificationTeams = engine.data.qualificationTeams;
      final expectedTeams = allNationalTeams
          .where((team) => team.continent == entry.value)
          .toList();
      expect(
        qualificationTeams.map((team) => team.id).toSet(),
        expectedTeams.map((team) => team.id).toSet(),
      );
      expect(
        qualificationTeams.every((team) => team.continent == entry.value),
        isTrue,
      );
      expect(
        engine.data.qualificationGroups
            .expand((group) => group.table)
            .any((row) => row.team.id == selected.id),
        isTrue,
      );

      final qualificationEvents = engine.eventManager.events
          .whereType<MatchEvent>()
          .where(
            (event) =>
                event.match.competition.type ==
                CompetitionType.worldCupQualifiers,
          );
      expect(qualificationEvents, isNotEmpty);
      expect(
        qualificationEvents.every(
          (event) =>
              event.match.homeTeam.continent == entry.value &&
              event.match.awayTeam.continent == entry.value,
        ),
        isTrue,
      );

      final nextMatch = engine.nextPlayerMatch;
      expect(nextMatch, isNotNull);
      expect(
        nextMatch!.match.homeTeam.id == selected.id ||
            nextMatch.match.awayTeam.id == selected.id,
        isTrue,
      );
    });
  }

  test('CONMEBOL contains exactly its ten database teams', () {
    final engine = GameEngine.instance;
    final brazil = allNationalTeams.singleWhere((team) => team.id == 'bra');
    engine.data.selectedCountry = brazil.name;

    engine.startGame();

    expect(engine.data.qualificationTeams.map((team) => team.id).toSet(), {
      'arg',
      'bol',
      'bra',
      'chi',
      'col',
      'ecu',
      'par',
      'per',
      'uru',
      'ven',
    });
    expect(engine.data.qualificationGroups, hasLength(1));
    expect(engine.data.qualificationGroups.single.table, hasLength(10));
  });

  test('Brazil live match is the exact scheduled qualification match', () {
    final engine = GameEngine.instance;
    final brazil = allNationalTeams.singleWhere((team) => team.id == 'bra');
    engine.data.selectedCountry = brazil.name;

    engine.startGame();

    final scheduledEvent = engine.nextPlayerMatch;
    expect(scheduledEvent, isNotNull);
    expect(
      scheduledEvent!.match.competition.type,
      CompetitionType.worldCupQualifiers,
    );

    final liveEvents = engine.skipToNextMatch();

    expect(liveEvents, hasLength(1));
    expect(liveEvents.single, same(scheduledEvent));
    expect(liveEvents.single.match, same(scheduledEvent.match));
    expect(
      liveEvents.single.match.homeTeam.continent,
      ContinentType.southAmerica,
    );
    expect(
      liveEvents.single.match.awayTeam.continent,
      ContinentType.southAmerica,
    );
  });
}
