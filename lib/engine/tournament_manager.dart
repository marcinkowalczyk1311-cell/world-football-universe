import '../models/timeline_message.dart';
import '../models/tournament.dart';
import 'match.dart';

class TournamentManager {
  TournamentManager._();
  static final instance = TournamentManager._();
  final List<TournamentChampion> _history = [];
  final List<TimelineMessage> _timeline = [];

  List<TournamentChampion> get history => List.unmodifiable(_history);
  List<TimelineMessage> get timeline => List.unmodifiable(_timeline);

  void reset() {
    _history.clear();
    _timeline.clear();
  }

  void announce(DateTime date, String message) {
    if (_timeline.any((item) => item.date == date && item.message == message)) {
      return;
    }
    _timeline.add(TimelineMessage(date: date, message: message));
    _timeline.sort((a, b) => b.date.compareTo(a.date));
  }

  void onMatchFinished(Match match) {
    final stage = match.tournamentStage;
    if (stage == null || !match.isPlayed) return;
    final winner = match.homeGoals! >= match.awayGoals!
        ? match.homeTeam
        : match.awayTeam;
    final loser = identical(winner, match.homeTeam)
        ? match.awayTeam
        : match.homeTeam;
    if (stage == TournamentStage.qualification) {
      announce(
        match.date,
        '${winner.name} qualified for ${match.competition.name}.',
      );
    } else if (stage == TournamentStage.knockoutStage &&
        !match.isTournamentFinal) {
      announce(
        match.date,
        '${loser.name} eliminated from ${match.competition.name}.',
      );
    }
    if (match.isTournamentFinal && match.tournamentEditionId != null) {
      final parts = match.tournamentEditionId!.split('_');
      final year = int.tryParse(parts.last) ?? match.date.year;
      if (!_history.any(
        (item) =>
            item.tournamentId == match.competition.id && item.year == year,
      )) {
        _history.add(
          TournamentChampion(
            tournamentId: match.competition.id,
            tournamentName: match.competition.name,
            year: year,
            winner: winner,
          ),
        );
        _history.sort((a, b) => b.year.compareTo(a.year));
        announce(match.date, '${winner.name} wins ${match.competition.name}.');
      }
    }
  }
}
