import 'dart:math';

import 'match.dart';

enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  injury,
  missedPenalty,
  penaltyGoal,
  ownGoal,
}

extension MatchEventIcon on MatchEventType {
  String get icon => switch (this) {
    MatchEventType.yellowCard => '\u{1F7E8}',
    MatchEventType.redCard => '\u{1F7E5}',
    MatchEventType.substitution => '\u{1F504}',
    MatchEventType.injury => '\u{1FA79}',
    MatchEventType.missedPenalty => '\u274C',
    _ => '\u26BD',
  };
}

class LiveMatchEvent {
  final int minute, homeGoals, awayGoals;
  final MatchEventType type;
  final String description;
  const LiveMatchEvent(
    this.minute,
    this.type,
    this.description,
    this.homeGoals,
    this.awayGoals,
  );
}

class TeamMatchStatistics {
  final int possession,
      shots,
      shotsOnTarget,
      corners,
      fouls,
      yellowCards,
      redCards;
  const TeamMatchStatistics(
    this.possession,
    this.shots,
    this.shotsOnTarget,
    this.corners,
    this.fouls,
    this.yellowCards,
    this.redCards,
  );
}

class MatchStatistics {
  final TeamMatchStatistics home, away;
  const MatchStatistics(this.home, this.away);
}

class LiveMatchSimulation {
  final List<LiveMatchEvent> events;
  final MatchStatistics statistics;
  final String manOfTheMatch;
  const LiveMatchSimulation(this.events, this.statistics, this.manOfTheMatch);
}

class MatchEngine {
  MatchEngine({Random? random}) : _random = random ?? Random();
  final Random _random;
  static const _roles = [
    'goalkeeper',
    'captain',
    'centre-back',
    'midfielder',
    'playmaker',
    'winger',
    'striker',
  ];

  void play(Match match, {int? homeGoals, int? awayGoals}) {
    if (match.isPlayed) return;

    match.homeGoals = homeGoals ?? _random.nextInt(6);
    match.awayGoals = awayGoals ?? _random.nextInt(6);
  }

  LiveMatchSimulation createLiveSimulation(Match match) {
    final hg = _goals(match.homeTeam.fifaRanking),
        ag = _goals(match.awayTeam.fifaRanking);
    final drafts = <_Draft>[];
    for (var i = 0; i < hg; i++) {
      drafts.add(_goal(match.homeTeam.name, true));
    }
    for (var i = 0; i < ag; i++) {
      drafts.add(_goal(match.awayTeam.name, false));
    }
    final hy = _random.nextInt(4), ay = _random.nextInt(4);
    final hr = _random.nextDouble() < .09 ? 1 : 0,
        ar = _random.nextDouble() < .09 ? 1 : 0;
    for (var i = 0; i < hy; i++) {
      drafts.add(_card(match.homeTeam.name, true, false));
    }
    for (var i = 0; i < ay; i++) {
      drafts.add(_card(match.awayTeam.name, false, false));
    }
    if (hr == 1) drafts.add(_card(match.homeTeam.name, true, true));
    if (ar == 1) drafts.add(_card(match.awayTeam.name, false, true));
    for (final home in [true, false]) {
      final team = home ? match.homeTeam.name : match.awayTeam.name;
      for (var i = 0; i < 2 + _random.nextInt(4); i++) {
        drafts.add(
          _Draft(
            46 + _random.nextInt(43),
            MatchEventType.substitution,
            '$team substitution',
            home,
          ),
        );
      }
      if (_random.nextDouble() < .08) {
        drafts.add(
          _Draft(
            10 + _random.nextInt(79),
            MatchEventType.injury,
            '$team player injured',
            home,
          ),
        );
      }
      if (_random.nextDouble() < .055) {
        drafts.add(
          _Draft(
            5 + _random.nextInt(84),
            MatchEventType.missedPenalty,
            '$team missed a penalty',
            home,
          ),
        );
      }
    }
    drafts.sort((a, b) => a.minute.compareTo(b.minute));
    var hs = 0, as = 0;
    final events = <LiveMatchEvent>[];
    for (final draft in drafts) {
      if (draft.isGoal) draft.home ? hs++ : as++;
      final score = '${match.homeTeam.name} $hs-$as ${match.awayTeam.name}';
      events.add(
        LiveMatchEvent(
          draft.minute,
          draft.type,
          draft.isGoal ? '${draft.text} - $score' : draft.text,
          hs,
          as,
        ),
      );
    }
    final winner = hg == ag
        ? (_random.nextBool() ? match.homeTeam.name : match.awayTeam.name)
        : (hg > ag ? match.homeTeam.name : match.awayTeam.name);
    return LiveMatchSimulation(
      events,
      _stats(hg, ag, hy, ay, hr, ar),
      '$winner ${_roles[_random.nextInt(_roles.length)]}',
    );
  }

  int _goals(int rank) {
    final chance =
        .22 +
        (rank <= 10
            ? .18
            : rank <= 30
            ? .08
            : 0);
    var result = 0;
    for (var i = 0; i < 5; i++) {
      if (_random.nextDouble() < chance) {
        result++;
      }
    }
    return result;
  }

  _Draft _goal(String team, bool home) {
    final roll = _random.nextDouble();
    final type = roll < .08
        ? MatchEventType.penaltyGoal
        : roll < .095
        ? MatchEventType.ownGoal
        : MatchEventType.goal;
    final text = type == MatchEventType.penaltyGoal
        ? '$team score from the penalty spot'
        : type == MatchEventType.ownGoal
        ? '$team awarded an own goal'
        : '$team score';
    return _Draft(2 + _random.nextInt(88), type, text, home);
  }

  _Draft _card(String team, bool home, bool red) {
    final role = _roles[1 + _random.nextInt(_roles.length - 1)];
    return _Draft(
      5 + _random.nextInt(85),
      red ? MatchEventType.redCard : MatchEventType.yellowCard,
      red ? '$team $role sent off' : '$team $role booked',
      home,
    );
  }

  MatchStatistics _stats(int hg, int ag, int hy, int ay, int hr, int ar) {
    final hp = (50 + (hg - ag).clamp(-3, 3) * 3 + _random.nextInt(9) - 4).clamp(
      34,
      66,
    );
    final hot = max(hg, hg + 2 + _random.nextInt(5)),
        aot = max(ag, ag + 2 + _random.nextInt(5));
    final hs = hot + 3 + _random.nextInt(8), ass = aot + 3 + _random.nextInt(8);
    return MatchStatistics(
      TeamMatchStatistics(
        hp,
        hs,
        hot,
        max(1, hs ~/ 3 + _random.nextInt(3) - 1),
        7 + _random.nextInt(10) + hy,
        hy,
        hr,
      ),
      TeamMatchStatistics(
        100 - hp,
        ass,
        aot,
        max(1, ass ~/ 3 + _random.nextInt(3) - 1),
        7 + _random.nextInt(10) + ay,
        ay,
        ar,
      ),
    );
  }
}

class _Draft {
  final int minute;
  final MatchEventType type;
  final String text;
  final bool home;
  const _Draft(this.minute, this.type, this.text, this.home);
  bool get isGoal =>
      type == MatchEventType.goal ||
      type == MatchEventType.penaltyGoal ||
      type == MatchEventType.ownGoal;
}
