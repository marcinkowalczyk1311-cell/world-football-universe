import 'package:flutter/foundation.dart';

import '../data/tournaments.dart';
import 'competition_qualification_generators.dart';
import 'event_manager.dart';
import 'fifa_ranking.dart';
import 'game_clock.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'match_event.dart';
import 'match_history.dart';
import 'international_calendar.dart';
import 'international_schedule_generator.dart';
import 'tournament_manager.dart';
import 'world.dart';

class GameEngine {
  GameEngine._();

  static final GameEngine instance = GameEngine._();

  final GameClock clock = GameClock();
  final World world = World();
  final GameData data = GameData();
  final EventManager eventManager = EventManager();
  final InternationalCalendar internationalCalendar = InternationalCalendar();
  TournamentManager get tournamentManager => TournamentManager.instance;

  GameState state = GameState.menu;

  void startGame() {
    debugPrint("========== GAME START ==========");

    state = GameState.loading;

    world.initialize();
    clock.reset();

    eventManager.clear();
    tournamentManager.reset();
    MatchHistory.clear();
    final selectedCountry = data.selectedCountry;
    if (selectedCountry == null) {
      throw StateError('A national team must be selected before starting.');
    }
    final playerTeam = world.getNationalTeam(selectedCountry);
    data.initializeCareer(playerTeam);

    FifaRanking.initialize(world.nationalTeams);

    final worldCup = internationalTournaments.singleWhere(
      (tournament) => tournament.id == 'FIFA_WORLD_CUP',
    );
    data.qualification =
        QualificationGeneratorRegistry.forTournament(worldCup.id).generate(
          tournament: worldCup,
          teams: world.nationalTeams,
          confederation: playerTeam.continent,
          playerTeam: playerTeam,
          startDate: clock.currentDate.add(const Duration(days: 7)),
          finalsYear: 2030,
        );
    tournamentManager.registerQualification(
      qualification: data.qualification!,
      date: data.qualification!.fixtures
          .map((match) => match.date)
          .reduce((first, second) => first.isBefore(second) ? first : second),
    );

    final fixtures = [...data.qualification!.fixtures]
      ..sort((first, second) {
        final byDate = first.date.compareTo(second.date);
        if (byDate != 0) return byDate;
        final firstIsPlayerMatch =
            first.homeTeam.id == playerTeam.id ||
            first.awayTeam.id == playerTeam.id;
        final secondIsPlayerMatch =
            second.homeTeam.id == playerTeam.id ||
            second.awayTeam.id == playerTeam.id;
        return firstIsPlayerMatch == secondIsPlayerMatch
            ? 0
            : (firstIsPlayerMatch ? -1 : 1);
      });
    for (var index = 0; index < fixtures.length; index++) {
      final match = fixtures[index];
      eventManager.addEvent(
        MatchEvent(
          id: 'QUALIFICATION_$index',
          title: data.qualification!.competition.name,
          description: '${match.homeTeam.name} vs ${match.awayTeam.name}',
          date: match.date,
          match: match,
        ),
      );
    }
    InternationalScheduleGenerator(calendar: internationalCalendar).generate(
      playerTeam: playerTeam,
      teams: world.nationalTeams,
      from: DateTime(2027),
      throughYear: 2034,
      eventManager: eventManager,
    );

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
    final nextMatch = nextPlayerMatch;

    if (nextMatch == null) {
      return const [];
    }

    final playerMatches = <MatchEvent>[];
    while (clock.currentDate.isBefore(nextMatch.date)) {
      playerMatches.addAll(nextDay());
    }
    return playerMatches;
  }

  MatchEvent? get nextPlayerMatch {
    final teamName = data.selectedTeam?.name ?? data.selectedCountry;
    return teamName == null ? null : eventManager.nextMatchFor(teamName);
  }
}
