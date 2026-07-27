import 'package:flutter/foundation.dart';

import 'calendar_generator.dart';
import 'event_manager.dart';
import 'fifa_ranking.dart';
import 'game_clock.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'qualification_generator.dart';
import 'match_event.dart';
import 'match_history.dart';
import 'qualification_schedule_generator.dart';
import 'world.dart';

class GameEngine {
  GameEngine._();

  static final GameEngine instance = GameEngine._();

  final GameClock clock = GameClock();
  final World world = World();
  final GameData data = GameData();
  final EventManager eventManager = EventManager();

  GameState state = GameState.menu;

  void startGame() {
    debugPrint("========== GAME START ==========");

    state = GameState.loading;

    world.initialize();
    clock.reset();

    eventManager.clear();
    MatchHistory.clear();
    // Ranking FIFA
    FifaRanking.initialize(world.nationalTeams);

    // Losowanie grup kwalifikacyjnych Europy
    data.qualificationGroups = QualificationGenerator().generateEuropeanGroups(
      world.nationalTeams,
    );

    // Wygeneruj terminarze kwalifikacji
    final scheduleGenerator = QualificationScheduleGenerator();

    for (final group in data.qualificationGroups) {
      final matches = scheduleGenerator.generate(
        group,
        startDate: clock.currentDate.add(const Duration(days: 7)),
      );

      for (var index = 0; index < matches.length; index++) {
        final match = matches[index];
        eventManager.addEvent(
          MatchEvent(
            id: 'WCQ_${group.name}_$index',
            title: 'World Cup Qualifiers',
            description: '${match.homeTeam.name} vs ${match.awayTeam.name}',
            date: match.date,
            match: match,
          ),
        );
      }

      debugPrint(
        "Grupa ${group.name}: wygenerowano ${matches.length} meczów kwalifikacyjnych.",
      );
    }

    // Kalendarz meczów towarzyskich
    CalendarGenerator().generateFriendlyMatches();

    state = GameState.playing;

    debugPrint("Kontynent: ${data.selectedContinent}");
    debugPrint("Kraj: ${data.selectedCountry}");
    debugPrint("Data: ${clock.currentDate}");
    debugPrint("Liczba wydarzeń: ${eventManager.eventCount}");
    debugPrint("Liczba grup: ${data.qualificationGroups.length}");
    debugPrint("Stan gry: $state");

    debugPrint("================================");
  }

  List<MatchEvent> nextDay() {
    clock.nextDay();

    debugPrint("Nowa data: ${clock.currentDate}");
    debugPrint("Przetwarzanie wydarzeń dla: ${clock.currentDate}");

    return eventManager.processEvents(
      clock.currentDate,
      playerTeamName: data.selectedCountry,
    );
  }

  List<MatchEvent> skipToNextMatch() {
    final nextMatch = eventManager.nextMatch;

    if (nextMatch == null) {
      return const [];
    }

    final playerMatches = <MatchEvent>[];
    while (clock.currentDate.isBefore(nextMatch.date)) {
      playerMatches.addAll(nextDay());
    }
    return playerMatches;
  }
}
