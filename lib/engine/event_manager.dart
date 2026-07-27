import 'package:flutter/foundation.dart';

import 'game_event.dart';
import 'match_event.dart';

class EventManager {
  final List<GameEvent> _events = [];

  void addEvent(GameEvent event) {
    _events.add(event);

    debugPrint("Dodano wydarzenie: ${event.title}");
  }

  void clear() {
    _events.clear();
  }

  List<MatchEvent> processEvents(
    DateTime currentDate, {
    String? playerTeamName,
  }) {
    final eventsForToday = _events
        .where(
          (event) =>
              event.date.year == currentDate.year &&
              event.date.month == currentDate.month &&
              event.date.day == currentDate.day,
        )
        .toList();

    final deferredMatches = <MatchEvent>[];

    for (final event in eventsForToday) {
      if (event is MatchEvent &&
          playerTeamName != null &&
          (event.match.homeTeam.name == playerTeamName ||
              event.match.awayTeam.name == playerTeamName)) {
        deferredMatches.add(event);
      } else {
        event.execute();
      }
    }

    _events.removeWhere(
      (event) =>
          event.date.year == currentDate.year &&
          event.date.month == currentDate.month &&
          event.date.day == currentDate.day,
    );

    return deferredMatches;
  }

  /// Wszystkie zaplanowane wydarzenia.
  List<GameEvent> get events => List.unmodifiable(_events);

  /// Najbliższy zaplanowany mecz.
  MatchEvent? get nextMatch {
    return nextMatchFor();
  }

  MatchEvent? nextMatchFor([String? teamName]) {
    final matches = _events
        .whereType<MatchEvent>()
        .where(
          (event) =>
              teamName == null ||
              event.match.homeTeam.name == teamName ||
              event.match.awayTeam.name == teamName,
        )
        .toList();

    if (matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) => a.date.compareTo(b.date));

    return matches.first;
  }

  int get eventCount => _events.length;
}
