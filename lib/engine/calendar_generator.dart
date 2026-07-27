import '../models/competition.dart';
import '../models/competition_type.dart';
import 'game_engine.dart';
import 'match.dart';
import 'match_event.dart';

class CalendarGenerator {
  final GameEngine engine = GameEngine.instance;

  void generateFriendlyMatches() {
    final teams = engine.world.nationalTeams;

    if (teams.length < 2) return;

    final playerTeam = engine.world.getNationalTeam(
      engine.data.selectedCountry!,
    );

    int dayOffset = 0;

    const friendlyCompetition = Competition(
      id: "friendly",
      name: "Mecz towarzyski",
      shortName: "TOW",
      type: CompetitionType.friendly,
    );

    for (final opponent in teams) {
      if (opponent.name == playerTeam.name) {
        continue;
      }

      dayOffset += 7;

      final match = Match(
        homeTeam: playerTeam,
        awayTeam: opponent,
        date: engine.clock.currentDate.add(
          Duration(days: dayOffset),
        ),
        competition: friendlyCompetition,
      );

      engine.eventManager.addEvent(
        MatchEvent(
          id: "FRIENDLY_$dayOffset",
          title: "Mecz towarzyski",
          description: "${playerTeam.name} vs ${opponent.name}",
          date: match.date,
          match: match,
        ),
      );

      if (dayOffset >= 35) {
        break;
      }
    }
  }
}