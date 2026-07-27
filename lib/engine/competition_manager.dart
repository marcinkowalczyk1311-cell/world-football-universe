import '../models/competition_type.dart';
import 'match.dart';
import 'qualification_table_manager.dart';

class CompetitionManager {
  final QualificationTableManager _tableManager =
  QualificationTableManager();

  void onMatchFinished(Match match) {
    switch (match.competition.type) {
      case CompetitionType.friendly:
        _handleFriendly(match);
        break;

      case CompetitionType.worldCupQualifiers:
        _handleWorldCupQualifiers(match);
        break;

      case CompetitionType.worldCup:
        _handleWorldCup(match);
        break;

      case CompetitionType.continentalQualifiers:
        _handleContinentalQualifiers(match);
        break;

      case CompetitionType.continentalCup:
        _handleContinentalCup(match);
        break;

      case CompetitionType.nationsLeague:
        _handleNationsLeague(match);
        break;
    }
  }

  void _handleFriendly(Match match) {
    // Mecze towarzyskie nie wpływają na tabele.
  }

  void _handleWorldCupQualifiers(Match match) {
    _tableManager.processMatch(match);
  }

  void _handleWorldCup(Match match) {
    // Obsługa Mistrzostw Świata.
  }

  void _handleContinentalQualifiers(Match match) {
    // Obsługa kwalifikacji do Euro.
  }

  void _handleContinentalCup(Match match) {
    // Obsługa Euro.
  }

  void _handleNationsLeague(Match match) {
    // Obsługa Ligi Narodów.
  }
}