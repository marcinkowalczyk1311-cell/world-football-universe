import 'package:flutter/material.dart';

import '../engine/game_engine.dart';
import '../engine/match_event.dart';
import '../widgets/career_header.dart';
import '../widgets/match_history_card.dart';
import '../widgets/next_match_card.dart';
import '../widgets/qualification_tables.dart';
import '../widgets/statistics_card.dart';
import 'fifa_ranking_screen.dart';
import 'match_screen.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  final engine = GameEngine.instance;

  Future<void> _advance(List<MatchEvent> Function() advance) async {
    final playerMatches = advance();
    if (playerMatches.isNotEmpty && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MatchScreen(matches: playerMatches)),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('World Football Universe'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.home_outlined), text: 'Overview'),
              Tab(
                icon: Icon(Icons.table_chart_outlined),
                text: 'Qualification Tables',
              ),
              Tab(icon: Icon(Icons.history), text: 'Match History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverview(),
            QualificationTables(
              groups: engine.data.qualificationGroups,
              selectedTeamName: engine.data.selectedCountry,
            ),
            const _MatchHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final MatchEvent? nextMatch = engine.eventManager.nextMatch;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CareerHeader(
          country: engine.data.selectedCountry ?? '-',
          date: engine.clock.currentDate,
        ),
        const SizedBox(height: 20),
        NextMatchCard(nextMatch: nextMatch),
        const SizedBox(height: 20),
        StatisticsCard(teamName: engine.data.selectedCountry ?? ''),
        const SizedBox(height: 20),
        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.public),
            label: const Text('FIFA Ranking', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FifaRankingScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _advance(engine.nextDay),
            icon: const Icon(Icons.skip_next),
            label: const Text('Next day', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _advance(engine.skipToNextMatch),
            icon: const Icon(Icons.sports_soccer),
            label: const Text(
              'Skip to next match',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MatchHistoryTab extends StatelessWidget {
  const _MatchHistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Match History',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        MatchHistoryCard(),
      ],
    );
  }
}
