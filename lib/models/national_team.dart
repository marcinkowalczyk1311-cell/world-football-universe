import 'continent_type.dart';

class NationalTeam {
  final String name;

  final String flag;

  final ContinentType continent;

  int fifaRanking;

  NationalTeam({
    required this.name,
    required this.flag,
    required this.continent,
    required this.fifaRanking,
  });
}