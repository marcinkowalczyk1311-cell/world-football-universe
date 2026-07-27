import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/data/national_teams.dart';
import 'package:football_simulator/data/tournaments.dart';
import 'package:football_simulator/engine/game_engine.dart';
import 'package:football_simulator/engine/international_calendar.dart';
import 'package:football_simulator/engine/match.dart';
import 'package:football_simulator/engine/tournament_manager.dart';
import 'package:football_simulator/models/competition.dart';
import 'package:football_simulator/models/competition_type.dart';
import 'package:football_simulator/models/continent_type.dart';
import 'package:football_simulator/models/tournament.dart';

void main() {
  test('all requested official competitions are defined', () {
    expect(internationalTournaments.map((item) => item.id).toSet(), {
      'FIFA_WORLD_CUP',
      'UEFA_EURO',
      'COPA_AMERICA',
      'AFC_ASIAN_CUP',
      'AFRICA_CUP_OF_NATIONS',
      'CONCACAF_GOLD_CUP',
      'OFC_NATIONS_CUP',
      'UEFA_NATIONS_LEAGUE',
    });
  });

  test('official windows suppress friendlies', () {
    final calendar = InternationalCalendar();
    final window = calendar.activeWindow(
      DateTime(2027, 9, 20),
      confederation: ContinentType.europe,
    );
    expect(window, isNotNull);
    expect(window!.isOfficial, isTrue);
    expect(window.isFriendly, isFalse);
  });

  test('friendly opponent is nearby in ranking and prefers confederation', () {
    final calendar = InternationalCalendar();
    final japan = allNationalTeams.singleWhere((team) => team.id == 'jpn');
    final opponent = calendar.friendlyOpponent(japan, allNationalTeams);
    expect(opponent.continent, japan.continent);
    expect((opponent.fifaRanking - japan.fifaRanking).abs(), lessThan(20));
  });

  test('career includes qualification, group, knockout and final fixtures', () {
    final engine = GameEngine.instance;
    engine.data.selectedCountry = allNationalTeams
        .singleWhere((team) => team.id == 'esp')
        .name;
    engine.startGame();
    final matches = engine.eventManager.events
        .whereType<dynamic>()
        .where((event) => event.match is Match)
        .map<Match>((event) => event.match as Match)
        .toList();
    expect(
      matches.any(
        (match) => match.tournamentStage == TournamentStage.qualification,
      ),
      isTrue,
    );
    expect(
      matches.any(
        (match) => match.tournamentStage == TournamentStage.groupStage,
      ),
      isTrue,
    );
    expect(
      matches.any(
        (match) => match.tournamentStage == TournamentStage.knockoutStage,
      ),
      isTrue,
    );
    expect(matches.any((match) => match.isTournamentFinal), isTrue);
  });

  test('a final permanently records its champion and timeline message', () {
    final manager = TournamentManager.instance..reset();
    final spain = allNationalTeams.singleWhere((team) => team.id == 'esp');
    final brazil = allNationalTeams.singleWhere((team) => team.id == 'bra');
    final match =
        Match(
            homeTeam: spain,
            awayTeam: brazil,
            date: DateTime(2030, 7, 18),
            competition: const Competition(
              id: 'FIFA_WORLD_CUP',
              name: 'FIFA World Cup',
              shortName: 'World Cup',
              type: CompetitionType.worldCup,
            ),
            tournamentEditionId: 'FIFA_WORLD_CUP_2030',
            tournamentStage: TournamentStage.knockoutStage,
            isTournamentFinal: true,
          )
          ..homeGoals = 2
          ..awayGoals = 1;
    manager.onMatchFinished(match);
    expect(manager.history.single.winner, same(spain));
    expect(manager.timeline.single.message, contains('wins FIFA World Cup'));
  });
}
