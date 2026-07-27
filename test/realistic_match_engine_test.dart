import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/data/competitions.dart';
import 'package:football_simulator/data/national_teams.dart';
import 'package:football_simulator/engine/fifa_ranking.dart';
import 'package:football_simulator/engine/match.dart';
import 'package:football_simulator/engine/match_engine.dart';

void main() {
  final spain = allNationalTeams.singleWhere((team) => team.id == 'esp');
  final gibraltar = allNationalTeams.singleWhere((team) => team.id == 'gib');
  final argentina = allNationalTeams.singleWhere((team) => team.id == 'arg');
  final brazil = allNationalTeams.singleWhere((team) => team.id == 'bra');

  Match fixture(home, away) => Match(
    homeTeam: home,
    awayTeam: away,
    date: DateTime(2026),
    competition: allCompetitions[2],
  );

  test('all teams have unique FIFA ranks and complete strength ratings', () {
    expect(
      allNationalTeams.map((team) => team.fifaRanking).toSet(),
      hasLength(211),
    );
    for (final team in allNationalTeams) {
      expect(team.attackRating, inInclusiveRange(0, 100));
      expect(team.midfieldRating, inInclusiveRange(0, 100));
      expect(team.defenceRating, inInclusiveRange(0, 100));
    }
  });

  test('strength creates realistic expected-goal separation', () {
    final engine = MatchEngine(random: Random(7));
    final mismatch = engine.expectedGoals(fixture(spain, gibraltar));
    final elite = engine.expectedGoals(fixture(brazil, argentina));
    expect(mismatch.$1, greaterThan(3.5));
    expect(mismatch.$2, lessThan(.4));
    expect((elite.$1 - elite.$2).abs(), lessThan(.5));
  });

  test('major upsets are rare across a large deterministic sample', () {
    final engine = MatchEngine(random: Random(42));
    var favouriteWins = 0, upsets = 0;
    for (var i = 0; i < 1200; i++) {
      final match = fixture(spain, gibraltar);
      engine.play(match);
      if (match.homeGoals! > match.awayGoals!) favouriteWins++;
      if (match.homeGoals! < match.awayGoals!) upsets++;
    }
    expect(favouriteWins / 1200, greaterThan(.9));
    expect(upsets / 1200, lessThan(.02));
  });

  test('Elo ranking rewards an upset more than an expected win', () {
    FifaRanking.initialize(allNationalTeams);
    final weakBefore = FifaRanking.getPoints(gibraltar.name);
    FifaRanking.updateAfterMatch(
      home: gibraltar,
      away: spain,
      homeGoals: 1,
      awayGoals: 0,
    );
    final upsetGain = FifaRanking.getPoints(gibraltar.name) - weakBefore;
    FifaRanking.initialize(allNationalTeams);
    final strongBefore = FifaRanking.getPoints(spain.name);
    FifaRanking.updateAfterMatch(
      home: spain,
      away: gibraltar,
      homeGoals: 1,
      awayGoals: 0,
    );
    final expectedGain = FifaRanking.getPoints(spain.name) - strongBefore;
    expect(upsetGain, greaterThan(expectedGain * 3));
  });
}
