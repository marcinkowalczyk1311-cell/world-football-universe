import 'continent_type.dart';

class NationalTeam {
  final String id;
  final String name;
  final String flag;
  final ContinentType continent;
  int fifaRanking;
  final int overallRating;
  final int attackRating;
  final int midfieldRating;
  final int defenceRating;

  NationalTeam({
    required this.id,
    required this.name,
    required this.flag,
    required this.continent,
    required this.fifaRanking,
    required this.overallRating,
    required this.attackRating,
    required this.midfieldRating,
    required this.defenceRating,
  });
}
