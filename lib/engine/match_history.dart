import 'match.dart';

class MatchHistory {
  static final List<Match> _matches = [];

  static void add(Match match) {
    _matches.add(match);
  }

  static List<Match> get matches =>
      List.unmodifiable(_matches);

  static void clear() {
    _matches.clear();
  }
}