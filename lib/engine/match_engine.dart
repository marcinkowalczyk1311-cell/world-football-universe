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
  chance,
  shot,
  corner,
}

extension MatchEventIcon on MatchEventType {
  String get icon => switch (this) {
    MatchEventType.yellowCard => '\u{1F7E8}',
    MatchEventType.redCard => '\u{1F7E5}',
    MatchEventType.substitution => '\u{1F504}',
    MatchEventType.injury => '\u{1FA79}',
    MatchEventType.missedPenalty => '\u274C',
    MatchEventType.corner => '\u{1F6A9}',
    MatchEventType.chance || MatchEventType.shot => '\u{1F945}',
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
  final double expectedGoals;
  const TeamMatchStatistics(
    this.possession,
    this.shots,
    this.shotsOnTarget,
    this.corners,
    this.fouls,
    this.yellowCards,
    this.redCards,
    this.expectedGoals,
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
    final outcome = _simulate(match);
    match.homeGoals = homeGoals ?? outcome.$1;
    match.awayGoals = awayGoals ?? outcome.$2;
  }

  LiveMatchSimulation createLiveSimulation(Match match) {
    final xg = expectedGoals(match), hg = _poisson(xg.$1), ag = _poisson(xg.$2);
    final stats = _stats(match, hg, ag, xg.$1, xg.$2);
    final drafts = <_Draft>[];
    for (var i = 0; i < hg; i++) {
      drafts.add(_goal(match.homeTeam.name, true));
    }
    for (var i = 0; i < ag; i++) {
      drafts.add(_goal(match.awayTeam.name, false));
    }
    _addAttackingEvents(drafts, match.homeTeam.name, true, stats.home);
    _addAttackingEvents(drafts, match.awayTeam.name, false, stats.away);
    final hy = _random.nextInt(4),
        ay = _random.nextInt(4),
        hr = _random.nextDouble() < .06 ? 1 : 0,
        ar = _random.nextDouble() < .06 ? 1 : 0;
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
      for (var i = 0; i < 3 + _random.nextInt(3); i++) {
        drafts.add(
          _Draft(
            46 + _random.nextInt(43),
            MatchEventType.substitution,
            '$team substitution',
            home,
          ),
        );
      }
    }
    drafts.sort((a, b) => a.minute.compareTo(b.minute));
    var hs = 0, as = 0;
    final events = <LiveMatchEvent>[];
    for (final d in drafts) {
      if (d.isGoal) {
        d.home ? hs++ : as++;
      }
      final score = '${match.homeTeam.name} $hs-$as ${match.awayTeam.name}';
      events.add(
        LiveMatchEvent(
          d.minute,
          d.type,
          d.isGoal ? '${d.text} - $score' : d.text,
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
      stats,
      '$winner ${_roles[_random.nextInt(_roles.length)]}',
    );
  }

  (double, double) expectedGoals(Match match) {
    double value(bool home) {
      final team = home ? match.homeTeam : match.awayTeam,
          opponent = home ? match.awayTeam : match.homeTeam;
      final edge =
          (team.attackRating - opponent.defenceRating) * .55 +
          (team.midfieldRating - opponent.midfieldRating) * .25 +
          (team.overallRating - opponent.overallRating) * .20;
      return (1.18 * exp(edge / 24) + (home ? .16 : 0)).clamp(.12, 4.6);
    }

    return (value(true), value(false));
  }

  (int, int) _simulate(Match match) {
    final xg = expectedGoals(match);
    return (_poisson(xg.$1), _poisson(xg.$2));
  }

  int _poisson(double lambda) {
    var limit = exp(-lambda), product = 1.0, count = 0;
    do {
      count++;
      product *= _random.nextDouble();
    } while (product > limit && count < 9);
    return count - 1;
  }

  MatchStatistics _stats(Match match, int hg, int ag, double hxg, double axg) {
    final midfieldEdge =
        match.homeTeam.midfieldRating - match.awayTeam.midfieldRating;
    final hp = (50 + midfieldEdge * .55 + 2 + _random.nextInt(7) - 3)
        .round()
        .clamp(27, 73);
    TeamMatchStatistics side(bool home) {
      final goals = home ? hg : ag, xg = home ? hxg : axg;
      final shots = max(goals, (6 + xg * 3.1 + _random.nextInt(5) - 2).round());
      final onTarget = max(
        goals,
        (shots * (.31 + xg * .018)).round().clamp(1, shots),
      );
      return TeamMatchStatistics(
        home ? hp : 100 - hp,
        shots,
        onTarget,
        max(0, (shots * .28 + _random.nextInt(3) - 1).round()),
        8 + _random.nextInt(8),
        _random.nextInt(4),
        _random.nextDouble() < .06 ? 1 : 0,
        xg,
      );
    }

    return MatchStatistics(side(true), side(false));
  }

  void _addAttackingEvents(
    List<_Draft> out,
    String team,
    bool home,
    TeamMatchStatistics stats,
  ) {
    final chances = max(1, (stats.shots - stats.shotsOnTarget) ~/ 3);
    for (var i = 0; i < chances; i++) {
      out.add(
        _Draft(
          2 + _random.nextInt(88),
          MatchEventType.chance,
          '$team create a dangerous chance',
          home,
        ),
      );
    }
    for (var i = 0; i < max(0, stats.shotsOnTarget ~/ 2); i++) {
      out.add(
        _Draft(
          2 + _random.nextInt(88),
          MatchEventType.shot,
          '$team force a save',
          home,
        ),
      );
    }
    for (var i = 0; i < stats.corners ~/ 2; i++) {
      out.add(
        _Draft(
          2 + _random.nextInt(88),
          MatchEventType.corner,
          '$team win a corner',
          home,
        ),
      );
    }
  }

  _Draft _goal(String team, bool home) {
    final r = _random.nextDouble();
    final type = r < .08
        ? MatchEventType.penaltyGoal
        : r < .095
        ? MatchEventType.ownGoal
        : MatchEventType.goal;
    return _Draft(
      2 + _random.nextInt(88),
      type,
      type == MatchEventType.penaltyGoal
          ? '$team score from the penalty spot'
          : type == MatchEventType.ownGoal
          ? '$team awarded an own goal'
          : '$team score',
      home,
    );
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
