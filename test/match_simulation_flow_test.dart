import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/engine/game_engine.dart';
import 'package:football_simulator/engine/match_history.dart';

void main() {
  test('next day simulates every match scheduled for the new date', () {
    final engine = GameEngine.instance;
    engine.data.selectedContinent = 'Europe';
    engine.data.selectedCountry = 'Polska';
    engine.startGame();

    final initialDate = engine.clock.currentDate;
    final firstMatchDate = engine.eventManager.nextMatch!.date;

    while (engine.clock.currentDate.isBefore(firstMatchDate)) {
      engine.nextDay();
    }

    expect(
      engine.clock.currentDate.difference(initialDate).inDays,
      firstMatchDate.difference(initialDate).inDays,
    );
    expect(MatchHistory.matches, isNotEmpty);
    expect(MatchHistory.matches.every((match) => match.isPlayed), isTrue);
    expect(
      engine.data.qualificationGroups
          .expand((group) => group.table)
          .any((row) => row.played > 0),
      isTrue,
    );
    expect(
      engine.eventManager.events.where((event) => event.date == firstMatchDate),
      isEmpty,
    );
  });
}
