import '../models/timeline_message.dart';
import '../models/tournament.dart';
import '../models/national_team.dart';
import '../models/qualification_group.dart';
import '../models/qualification_state.dart';
import 'match.dart';

class TournamentManager {
  TournamentManager._();
  static final instance = TournamentManager._();
  final List<TournamentChampion> _history = [];
  final List<TimelineMessage> _timeline = [];
  final Map<String, QualificationState> _qualifications = {};
  final Map<String, String> _groupLeaders = {};

  List<TournamentChampion> get history => List.unmodifiable(_history);
  List<TimelineMessage> get timeline => List.unmodifiable(_timeline);

  void reset() {
    _history.clear();
    _timeline.clear();
    _qualifications.clear();
    _groupLeaders.clear();
  }

  void announce(DateTime date, String message) {
    if (_timeline.any((item) => item.date == date && item.message == message)) {
      return;
    }
    _timeline.add(TimelineMessage(date: date, message: message));
    _timeline.sort((a, b) => b.date.compareTo(a.date));
  }

  void registerQualification({
    required QualificationState qualification,
    required DateTime date,
  }) {
    if (_qualifications.containsKey(qualification.editionId)) return;
    _qualifications[qualification.editionId] = qualification;
    final tournamentName = _tournamentName(qualification.competition.id);
    announce(date, '$tournamentName Qualifiers have begun.');
    for (final group in qualification.groups) {
      for (final team in group.teams) {
        announce(date, '${team.name} drawn into Group ${group.name}.');
      }
      _groupLeaders['${qualification.editionId}_${group.name}'] =
          group.table.first.team.id;
    }
  }

  void announceTournamentStart(DateTime date, String tournamentId) {
    final name = _tournamentName(tournamentId);
    announce(
      date,
      tournamentId == 'FIFA_WORLD_CUP' ? '$name kicks off.' : '$name begins.',
    );
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
      _onQualificationMatchFinished(match, winner, loser);
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
        announce(
          match.date,
          '${winner.name} wins ${_tournamentName(match.competition.id)}.',
        );
      }
    }
  }

  void _onQualificationMatchFinished(
    Match match,
    NationalTeam winner,
    NationalTeam loser,
  ) {
    final editionId = match.tournamentEditionId;
    final qualification = editionId == null ? null : _qualifications[editionId];
    if (qualification == null) return;
    final group = _groupFor(qualification, match.homeTeam.id);
    if (group == null) return;
    if (match.homeGoals == match.awayGoals) {
      if (qualification.fixtures.every((fixture) => fixture.isPlayed)) {
        _announceQualificationResult(qualification, match.date);
        _qualifications.remove(qualification.editionId);
      }
      return;
    }
    final leaderKey = '${qualification.editionId}_${group.name}';
    final previousLeader = _groupLeaders[leaderKey];
    final currentLeader = group.table.first.team;
    _groupLeaders[leaderKey] = currentLeader.id;
    final winnerRow = group.table.firstWhere((row) => row.team.id == winner.id);
    final winnerFixtures = qualification.fixtures
        .where(
          (fixture) =>
              fixture.isPlayed &&
              (fixture.homeTeam.id == winner.id ||
                  fixture.awayTeam.id == winner.id),
        )
        .toList();
    final winningStreak = _winningStreak(winnerFixtures, winner.id);
    if (previousLeader != currentLeader.id && currentLeader.id == winner.id) {
      announce(
        match.date,
        '${winner.name} moves to the top of Group ${group.name}.',
      );
    } else if (winnerRow.played >= 5 && winnerRow.losses == 0) {
      announce(
        match.date,
        '${winner.name} remains unbeaten after ${winnerRow.played} matches.',
      );
    } else if (winningStreak >= 3) {
      announce(match.date, '${winner.name} extends its winning streak.');
    } else if (winnerRow.played >= 3 &&
        (match.homeGoals! - match.awayGoals!).abs() <= 2) {
      announce(
        match.date,
        '${winner.name} secures an important victory over ${loser.name}.',
      );
    }
    if (qualification.fixtures.every((fixture) => fixture.isPlayed)) {
      _announceQualificationResult(qualification, match.date);
      _qualifications.remove(qualification.editionId);
    }
  }

  QualificationGroup? _groupFor(
    QualificationState qualification,
    String teamId,
  ) {
    for (final group in qualification.groups) {
      if (group.teams.any((team) => team.id == teamId)) return group;
    }
    return null;
  }

  int _winningStreak(List<Match> fixtures, String teamId) {
    fixtures.sort((a, b) => b.date.compareTo(a.date));
    var streak = 0;
    for (final fixture in fixtures) {
      final won =
          (fixture.homeTeam.id == teamId &&
              fixture.homeGoals! > fixture.awayGoals!) ||
          (fixture.awayTeam.id == teamId &&
              fixture.awayGoals! > fixture.homeGoals!);
      if (!won) break;
      streak++;
    }
    return streak;
  }

  void _announceQualificationResult(
    QualificationState qualification,
    DateTime date,
  ) {
    final tournamentName = _tournamentName(qualification.competition.id);
    final qualifiedIds = qualification.advancingTeams
        .map((team) => team.id)
        .toSet();
    for (final group in qualification.groups) {
      for (final row in group.table) {
        announce(
          date,
          qualifiedIds.contains(row.team.id)
              ? '${row.team.name} qualified for the $tournamentName.'
              : '${row.team.name} failed to qualify for the $tournamentName.',
        );
      }
    }
  }

  String _tournamentName(String competitionId) {
    final id = competitionId.replaceFirst('_QUALIFICATION', '');
    return switch (id) {
      'FIFA_WORLD_CUP' => 'FIFA World Cup',
      'UEFA_EURO' => 'UEFA EURO',
      'COPA_AMERICA' => 'Copa Am\u00e9rica',
      'AFC_ASIAN_CUP' => 'AFC Asian Cup',
      'AFRICA_CUP_OF_NATIONS' => 'Africa Cup of Nations',
      'CONCACAF_GOLD_CUP' => 'CONCACAF Gold Cup',
      'OFC_NATIONS_CUP' => 'OFC Nations Cup',
      'UEFA_NATIONS_LEAGUE' => 'UEFA Nations League',
      _ =>
        id
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0]}${word.substring(1).toLowerCase()}',
            )
            .join(' '),
    };
  }
}
