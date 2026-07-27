import 'continent_type.dart';

class NationalTeam {
  final String id;
  final String name;
  final String flag;
  final ContinentType continent;
  int fifaRanking;
  final int overallRating;

  NationalTeam({
    required this.id,
    required this.name,
    required this.flag,
    required this.continent,
    required this.fifaRanking,
    required this.overallRating,
  });
}
