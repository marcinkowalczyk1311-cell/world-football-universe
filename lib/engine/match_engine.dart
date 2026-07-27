import 'dart:math';

import 'match.dart';

class MatchEngine {
  final Random _random = Random();

  void play(Match match) {
    if (match.isPlayed) {
      return;
    }

    match.homeGoals = _random.nextInt(6);
    match.awayGoals = _random.nextInt(6);
  }
}