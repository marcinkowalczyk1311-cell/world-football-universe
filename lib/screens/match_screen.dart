import 'dart:async';

import 'package:flutter/material.dart';

import '../engine/match_engine.dart';
import '../engine/match_event.dart';

class MatchScreen extends StatefulWidget {
  final List<MatchEvent> matches;
  final Duration minuteDuration;
  final Duration fullTimeDuration;

  const MatchScreen({
    super.key,
    required this.matches,
    this.minuteDuration = const Duration(milliseconds: 350),
    this.fullTimeDuration = const Duration(seconds: 3),
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final ScrollController _timelineController = ScrollController();
  final List<LiveMatchEvent> _timeline = [];
  Timer? _timer;
  late LiveMatchSimulation _simulation;
  int _matchIndex = 0, _minute = 0, _homeGoals = 0, _awayGoals = 0;
  String _status = 'Starting';

  MatchEvent get _event => widget.matches[_matchIndex];
  bool get _isFullTime => _status == 'Full Time';

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  void _startMatch() {
    _minute = _homeGoals = _awayGoals = 0;
    _timeline.clear();
    _status = 'Live';
    _simulation = MatchEngine().createLiveSimulation(_event.match);
    _timer = Timer.periodic(widget.minuteDuration, (_) => _advanceMinute());
  }

  void _advanceMinute() {
    if (!mounted) return;
    setState(() {
      _minute++;
      for (final event in _simulation.events.where(
        (e) => e.minute == _minute,
      )) {
        _timeline.add(event);
        _homeGoals = event.homeGoals;
        _awayGoals = event.awayGoals;
      }
      if (_minute == 90) {
        _status = 'Full Time';
        _timer?.cancel();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timelineController.hasClients) {
        _timelineController.animateTo(
          _timelineController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    if (_minute == 90) _finishMatch();
  }

  Future<void> _finishMatch() async {
    _event.complete(homeGoals: _homeGoals, awayGoals: _awayGoals);
    await Future<void>.delayed(widget.fullTimeDuration);
    if (!mounted) return;
    if (_matchIndex + 1 < widget.matches.length) {
      setState(() {
        _matchIndex++;
        _startMatch();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = _event.match;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: Text(_isFullTime ? 'Full Time' : 'Live Match')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _status,
                  key: const Key('match-status'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isFullTime ? '90′' : "$_minute'",
                  key: const Key('match-minute'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.homeTeam.name,
                        key: const Key('home-team'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '$_homeGoals - $_awayGoals',
                      key: const Key('match-score'),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Expanded(
                      child: Text(
                        match.awayTeam.name,
                        key: const Key('away-team'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _isFullTime
                      ? _FullTimePanel(
                          simulation: _simulation,
                          homeTeam: match.homeTeam.name,
                          awayTeam: match.awayTeam.name,
                        )
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Timeline',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: _timeline.isEmpty
                                  ? const Center(
                                      child: Text('The match is settling in…'),
                                    )
                                  : ListView.builder(
                                      key: const Key('match-timeline'),
                                      controller: _timelineController,
                                      itemCount: _timeline.length,
                                      itemBuilder: (_, index) {
                                        final event = _timeline[index];
                                        return ListTile(
                                          dense: true,
                                          leading: Text(
                                            event.type.icon,
                                            style: const TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                          title: Text(
                                            "${event.minute}' ${event.description}",
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullTimePanel extends StatelessWidget {
  const _FullTimePanel({
    required this.simulation,
    required this.homeTeam,
    required this.awayTeam,
  });
  final LiveMatchSimulation simulation;
  final String homeTeam, awayTeam;

  @override
  Widget build(BuildContext context) {
    final home = simulation.statistics.home, away = simulation.statistics.away;
    return ListView(
      key: const Key('full-time-panel'),
      children: [
        Text(
          'Match Statistics',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _row('', homeTeam, awayTeam),
        _row('Possession', '${home.possession}%', '${away.possession}%'),
        _row('Shots', home.shots, away.shots),
        _row('Shots on target', home.shotsOnTarget, away.shotsOnTarget),
        _row('Corners', home.corners, away.corners),
        _row('Fouls', home.fouls, away.fouls),
        _row('Yellow cards', home.yellowCards, away.yellowCards),
        _row('Red cards', home.redCards, away.redCards),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Man of the Match'),
            subtitle: Text(simulation.manOfTheMatch),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, Object home, Object away) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text('$home', textAlign: TextAlign.center)),
        Expanded(child: Text(label, textAlign: TextAlign.center)),
        Expanded(child: Text('$away', textAlign: TextAlign.center)),
      ],
    ),
  );
}
