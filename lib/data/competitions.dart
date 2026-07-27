import '../models/competition.dart';
import '../models/competition_type.dart';

final List<Competition> allCompetitions = [
  Competition(
    id: "FRIENDLY",
    name: "Friendly Match",
    shortName: "Friendly",
    type: CompetitionType.friendly,
  ),
  Competition(
    id: "FIFA_WORLD_CUP",
    name: "FIFA World Cup",
    shortName: "World Cup",
    type: CompetitionType.worldCup,
  ),
  Competition(
    id: "WORLD_CUP_QUALIFIERS",
    name: "FIFA World Cup Qualifiers",
    shortName: "WC Qualifiers",
    type: CompetitionType.worldCupQualifiers,
  ),
  Competition(
    id: "UEFA_EURO",
    name: "UEFA European Championship",
    shortName: "EURO",
    type: CompetitionType.continentalCup,
  ),
  Competition(
    id: "EURO_QUALIFIERS",
    name: "UEFA EURO Qualifiers",
    shortName: "EURO Qualifiers",
    type: CompetitionType.continentalQualifiers,
  ),
  Competition(
    id: "UEFA_NATIONS_LEAGUE",
    name: "UEFA Nations League",
    shortName: "Nations League",
    type: CompetitionType.nationsLeague,
  ),
  Competition(
    id: "COPA_AMERICA",
    name: "Copa Am?rica",
    shortName: "Copa Am?rica",
    type: CompetitionType.continentalCup,
  ),
  Competition(
    id: "AFC_ASIAN_CUP",
    name: "AFC Asian Cup",
    shortName: "Asian Cup",
    type: CompetitionType.continentalCup,
  ),
  Competition(
    id: "AFRICA_CUP_OF_NATIONS",
    name: "Africa Cup of Nations",
    shortName: "AFCON",
    type: CompetitionType.continentalCup,
  ),
  Competition(
    id: "CONCACAF_GOLD_CUP",
    name: "CONCACAF Gold Cup",
    shortName: "Gold Cup",
    type: CompetitionType.continentalCup,
  ),
  Competition(
    id: "OFC_NATIONS_CUP",
    name: "OFC Nations Cup",
    shortName: "OFC Nations Cup",
    type: CompetitionType.continentalCup,
  ),
];
