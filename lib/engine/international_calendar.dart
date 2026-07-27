import '../data/tournaments.dart';
import '../models/continent_type.dart';
import '../models/national_team.dart';
import '../models/tournament.dart';

class InternationalWindow {
  final DateTime start, end;
  final TournamentDefinition? tournament;
  final TournamentStage? stage;
  final bool isFriendly;
  const InternationalWindow({
    required this.start,
    required this.end,
    this.tournament,
    this.stage,
    this.isFriendly = false,
  });
  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);
  bool get isOfficial => tournament != null;
}

class InternationalCalendar {
  List<InternationalWindow> windowsForYear(
    int year, {
    ContinentType? confederation,
  }) {
    final windows = <InternationalWindow>[];
    for (final tournament in internationalTournaments) {
      if (tournament.confederation != null &&
          tournament.confederation != confederation) {
        continue;
      }
      if (tournament.isFinalsYear(year)) {
        windows.add(
          InternationalWindow(
            start: DateTime(year, 6, 1),
            end: DateTime(year, 7, 20),
            tournament: tournament,
            stage: TournamentStage.groupStage,
          ),
        );
      }
      final nextFinal = _nextFinalsYear(tournament, year);
      if (tournament.hasQualification && nextFinal == year + 1) {
        for (final month in const [3, 9, 10, 11]) {
          windows.add(
            InternationalWindow(
              start: DateTime(year, month, 18),
              end: DateTime(year, month, 26),
              tournament: tournament,
              stage: TournamentStage.qualification,
            ),
          );
        }
      }
      if (tournament.id == 'UEFA_NATIONS_LEAGUE' && year.isEven) {
        for (final month in const [9, 10, 11]) {
          windows.add(
            InternationalWindow(
              start: DateTime(year, month, 18),
              end: DateTime(year, month, 26),
              tournament: tournament,
              stage: TournamentStage.groupStage,
            ),
          );
        }
      }
    }
    for (final month in const [3, 6, 9, 10, 11]) {
      final start = DateTime(year, month, 18), end = DateTime(year, month, 26);
      if (!windows.any(
        (window) => _overlaps(start, end, window.start, window.end),
      )) {
        windows.add(
          InternationalWindow(start: start, end: end, isFriendly: true),
        );
      }
    }
    windows.sort((a, b) => a.start.compareTo(b.start));
    return windows;
  }

  InternationalWindow? activeWindow(
    DateTime date, {
    ContinentType? confederation,
  }) {
    final active = windowsForYear(
      date.year,
      confederation: confederation,
    ).where((window) => window.contains(date)).toList();
    if (active.isEmpty) return null;
    active.sort(
      (a, b) => (b.isOfficial ? 1 : 0).compareTo(a.isOfficial ? 1 : 0),
    );
    return active.first;
  }

  NationalTeam friendlyOpponent(
    NationalTeam team,
    List<NationalTeam> teams, {
    Set<String> unavailable = const {},
  }) {
    final candidates =
        teams
            .where(
              (other) => other.id != team.id && !unavailable.contains(other.id),
            )
            .toList()
          ..sort((a, b) {
            final aScore =
                (a.fifaRanking - team.fifaRanking).abs() +
                (a.continent == team.continent ? 0 : 12);
            final bScore =
                (b.fifaRanking - team.fifaRanking).abs() +
                (b.continent == team.continent ? 0 : 12);
            return aScore.compareTo(bScore);
          });
    if (candidates.isEmpty) throw StateError('No available friendly opponent.');
    return candidates.first;
  }

  int _nextFinalsYear(TournamentDefinition tournament, int year) {
    var candidate = tournament.firstFinalsYear;
    while (candidate <= year) {
      candidate += tournament.cycleYears;
    }
    return candidate;
  }

  bool _overlaps(DateTime a, DateTime b, DateTime c, DateTime d) =>
      !b.isBefore(c) && !a.isAfter(d);
}
