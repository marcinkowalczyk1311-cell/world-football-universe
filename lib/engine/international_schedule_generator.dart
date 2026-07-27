import '../models/competition.dart';
import '../models/competition_type.dart';
import '../models/national_team.dart';
import '../models/tournament.dart';
import 'event_manager.dart';
import 'international_calendar.dart';
import 'match.dart';
import 'match_event.dart';
import 'tournament_manager.dart';

class InternationalScheduleGenerator {
  final InternationalCalendar calendar;
  InternationalScheduleGenerator({InternationalCalendar? calendar})
    : calendar = calendar ?? InternationalCalendar();

  void generate({
    required NationalTeam playerTeam,
    required List<NationalTeam> teams,
    required DateTime from,
    required int throughYear,
    required EventManager eventManager,
  }) {
    var sequence = 0;
    for (var year = from.year; year <= throughYear; year++) {
      final windows = calendar.windowsForYear(
        year,
        confederation: playerTeam.continent,
      );
      for (final window in windows) {
        if (!window.end.isAfter(from)) continue;
        if (window.isFriendly) {
          final date = window.start.add(const Duration(days: 3));
          final opponent = calendar.friendlyOpponent(playerTeam, teams);
          _add(
            eventManager,
            sequence++,
            Match(
              homeTeam: sequence.isEven ? playerTeam : opponent,
              awayTeam: sequence.isEven ? opponent : playerTeam,
              date: date,
              competition: const Competition(
                id: 'FRIENDLY',
                name: 'International Friendly',
                shortName: 'Friendly',
                type: CompetitionType.friendly,
              ),
            ),
          );
          continue;
        }
        // Qualification structures and fixtures are owned by the competition's
        // QualificationGenerator. The calendar only exposes the active window.
        if (window.stage == TournamentStage.qualification) {
          continue;
        }
        final tournament = window.tournament!;
        final eligible =
            teams
                .where(
                  (team) =>
                      (tournament.confederation == null &&
                          window.stage != TournamentStage.qualification) ||
                      team.continent ==
                          (tournament.confederation ?? playerTeam.continent),
                )
                .toList()
              ..sort((a, b) => a.fifaRanking.compareTo(b.fifaRanking));
        if (!eligible.any((team) => team.id == playerTeam.id)) continue;
        final competition = Competition(
          id: tournament.id,
          name: tournament.name,
          shortName: tournament.shortName,
          type: _typeFor(tournament, window.stage!),
        );
        if (window.stage == TournamentStage.qualification) {
          final opponent = _opponent(playerTeam, eligible, sequence);
          TournamentManager.instance.announce(
            window.start,
            '${tournament.name} qualification begins.',
          );
          _add(
            eventManager,
            sequence++,
            Match(
              homeTeam: sequence.isEven ? playerTeam : opponent,
              awayTeam: sequence.isEven ? opponent : playerTeam,
              date: window.start.add(const Duration(days: 3)),
              competition: competition,
              tournamentEditionId:
                  '${tournament.id}_${_nextFinalYear(tournament, year)}',
              tournamentStage: TournamentStage.qualification,
            ),
          );
        } else if (window.start.month == 6) {
          TournamentManager.instance.announce(
            window.start,
            '${tournament.name} begins.',
          );
          final opponents = List.generate(
            3,
            (index) => _opponent(playerTeam, eligible, sequence + index),
          );
          final dates = [
            DateTime(year, 6, 5),
            DateTime(year, 7, 5),
            DateTime(year, 7, 18),
          ];
          final stages = [
            TournamentStage.groupStage,
            TournamentStage.knockoutStage,
            TournamentStage.knockoutStage,
          ];
          for (var index = 0; index < 3; index++) {
            _add(
              eventManager,
              sequence++,
              Match(
                homeTeam: index.isEven ? playerTeam : opponents[index],
                awayTeam: index.isEven ? opponents[index] : playerTeam,
                date: dates[index],
                competition: competition,
                tournamentEditionId: '${tournament.id}_$year',
                tournamentStage: stages[index],
                isTournamentFinal: index == 2,
              ),
            );
          }
        } else {
          final opponent = _opponent(playerTeam, eligible, sequence);
          _add(
            eventManager,
            sequence++,
            Match(
              homeTeam: playerTeam,
              awayTeam: opponent,
              date: window.start.add(const Duration(days: 3)),
              competition: competition,
              tournamentEditionId: '${tournament.id}_$year',
              tournamentStage: TournamentStage.groupStage,
            ),
          );
        }
      }
    }
  }

  NationalTeam _opponent(
    NationalTeam team,
    List<NationalTeam> eligible,
    int seed,
  ) {
    final others =
        eligible.where((candidate) => candidate.id != team.id).toList()..sort(
          (a, b) => (a.fifaRanking - team.fifaRanking).abs().compareTo(
            (b.fifaRanking - team.fifaRanking).abs(),
          ),
        );
    return others[seed % others.length.clamp(1, 6)];
  }

  CompetitionType _typeFor(
    TournamentDefinition tournament,
    TournamentStage stage,
  ) {
    if (stage == TournamentStage.qualification) {
      return tournament.id == 'FIFA_WORLD_CUP'
          ? CompetitionType.worldCupQualifiers
          : CompetitionType.continentalQualifiers;
    }
    if (tournament.id == 'FIFA_WORLD_CUP') return CompetitionType.worldCup;
    if (tournament.id == 'UEFA_NATIONS_LEAGUE') {
      return CompetitionType.nationsLeague;
    }
    return CompetitionType.continentalCup;
  }

  int _nextFinalYear(TournamentDefinition tournament, int year) {
    var result = tournament.firstFinalsYear;
    while (result <= year) {
      result += tournament.cycleYears;
    }
    return result;
  }

  void _add(EventManager manager, int id, Match match) => manager.addEvent(
    MatchEvent(
      id: 'INT_$id',
      title: match.competition.name,
      description: '${match.homeTeam.name} vs ${match.awayTeam.name}',
      date: match.date,
      match: match,
    ),
  );
}
