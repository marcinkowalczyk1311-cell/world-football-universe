import '../models/continent_type.dart';
import '../models/national_team.dart';

final List<NationalTeam> allNationalTeams = [
  NationalTeam(
    name: "Polska",
    flag: "🇵🇱",
    continent: ContinentType.europe,
    fifaRanking: 32,
  ),
  NationalTeam(
    name: "Hiszpania",
    flag: "🇪🇸",
    continent: ContinentType.europe,
    fifaRanking: 2,
  ),
  NationalTeam(
    name: "Niemcy",
    flag: "🇩🇪",
    continent: ContinentType.europe,
    fifaRanking: 10,
  ),
  NationalTeam(
    name: "Argentyna",
    flag: "🇦🇷",
    continent: ContinentType.southAmerica,
    fifaRanking: 1,
  ),
  NationalTeam(
    name: "Brazylia",
    flag: "🇧🇷",
    continent: ContinentType.southAmerica,
    fifaRanking: 5,
  ),
];