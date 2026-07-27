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

  void processEvents(DateTime currentDate) {
    final eventsForToday = _events
        .where(
          (event) =>
              event.date.year == currentDate.year &&
              event.date.month == currentDate.month &&
              event.date.day == currentDate.day,
        )
        .toList();

    for (final event in eventsForToday) {
      event.execute();
    }

    _events.removeWhere(
      (event) =>
          event.date.year == currentDate.year &&
          event.date.month == currentDate.month &&
          event.date.day == currentDate.day,
    );
  }

  /// Wszystkie zaplanowane wydarzenia.
  List<GameEvent> get events => List.unmodifiable(_events);

  /// Najbliższy zaplanowany mecz.
  MatchEvent? get nextMatch {
    final matches = _events.whereType<MatchEvent>().toList();

    if (matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) => a.date.compareTo(b.date));

    return matches.first;
  }

  int get eventCount => _events.length;
}
