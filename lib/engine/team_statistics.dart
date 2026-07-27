import 'match_history.dart';

class TeamStatistics {
  final String teamName;

  int matches = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;

  int goalsFor = 0;
  int goalsAgainst = 0;

  TeamStatistics(this.teamName);

  void calculate() {
    matches = 0;
    wins = 0;
    draws = 0;
    losses = 0;
    goalsFor = 0;
    goalsAgainst = 0;

    for (final match in MatchHistory.matches) {
      bool played = false;

      int scored = 0;
      int conceded = 0;

      if (match.homeTeam.name == teamName) {
        played = true;
        scored = match.homeGoals ?? 0;
        conceded = match.awayGoals ?? 0;
      }

      if (match.awayTeam.name == teamName) {
        played = true;
        scored = match.awayGoals ?? 0;
        conceded = match.homeGoals ?? 0;
      }

      if (!played) {
        continue;
      }

      matches++;

      goalsFor += scored;
      goalsAgainst += conceded;

      if (scored > conceded) {
        wins++;
      } else if (scored == conceded) {
        draws++;
      } else {
        losses++;
      }
    }
  }
}