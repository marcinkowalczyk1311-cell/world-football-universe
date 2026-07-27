import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/match_event.dart';

class MatchScreen extends StatefulWidget {
  final List<MatchEvent> matches;
  final Duration minuteDuration;

  const MatchScreen({
    super.key,
    required this.matches,
    this.minuteDuration = const Duration(milliseconds: 350),
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final Random _random = Random();
  final ScrollController _timelineController = ScrollController();
  final List<String> _timeline = [];

  Timer? _timer;
  int _matchIndex = 0;
  int _minute = 0;
  int _homeGoals = 0;
  int _awayGoals = 0;
  String _status = 'Starting';

  MatchEvent get _event => widget.matches[_matchIndex];

  @override
  void initState() {
    super.initState();
    _startMatch();
  }

  void _startMatch() {
    _minute = 0;
    _homeGoals = 0;
    _awayGoals = 0;
    _timeline.clear();
    _status = 'Live';
    _timer = Timer.periodic(widget.minuteDuration, (_) => _advanceMinute());
  }

  void _advanceMinute() {
    if (!mounted) return;

    setState(() {
      _minute++;
      if (_random.nextDouble() < 0.028) {
        final homeScored = _random.nextBool();
        if (homeScored) {
          _homeGoals++;
        } else {
          _awayGoals++;
        }
        _timeline.add(
          "$_minute' ${_event.match.homeTeam.name} "
          '$_homeGoals-$_awayGoals ${_event.match.awayTeam.name}',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timelineController.hasClients) {
            _timelineController.animateTo(
              _timelineController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }

      if (_minute == 90) {
        _status = 'Full time';
        _timer?.cancel();
      }
    });

    if (_minute == 90) {
      _finishMatch();
    }
  }

  Future<void> _finishMatch() async {
    _event.complete(homeGoals: _homeGoals, awayGoals: _awayGoals);
    await Future<void>.delayed(const Duration(milliseconds: 600));
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
        appBar: AppBar(title: const Text('Live Match')),
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
                  "$_minute'",
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
                      ? const Center(child: Text('No goals yet'))
                      : ListView.builder(
                          key: const Key('match-timeline'),
                          controller: _timelineController,
                          itemCount: _timeline.length,
                          itemBuilder: (_, index) => ListTile(
                            leading: const Icon(Icons.sports_soccer),
                            title: Text(_timeline[index]),
                          ),
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
