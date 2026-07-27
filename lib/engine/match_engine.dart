import 'dart:math';

import 'match.dart';

class MatchEngine {
  final Random _random = Random();

  void play(Match match, {int? homeGoals, int? awayGoals}) {
    if (match.isPlayed) {
      return;
    }

    match.homeGoals = homeGoals ?? _random.nextInt(6);
    match.awayGoals = awayGoals ?? _random.nextInt(6);
  }
}
