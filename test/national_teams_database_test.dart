import 'package:flutter_test/flutter_test.dart';
import 'package:football_simulator/data/countries.dart';
import 'package:football_simulator/data/national_teams.dart';
import 'package:football_simulator/models/continent_type.dart';

void main() {
  const expectedConfederationSizes = <ContinentType, int>{
    ContinentType.europe: 55,
    ContinentType.southAmerica: 10,
    ContinentType.northAmerica: 35,
    ContinentType.africa: 54,
    ContinentType.asia: 46,
    ContinentType.oceania: 11,
  };

  test('database contains all 211 FIFA associations with valid fields', () {
    expect(allNationalTeams, hasLength(211));
    expect(allNationalTeams.map((team) => team.id).toSet(), hasLength(211));
    expect(allNationalTeams.map((team) => team.name).toSet(), hasLength(211));

    for (final team in allNationalTeams) {
      expect(team.id, isNotEmpty);
      expect(team.name, isNotEmpty);
      expect(team.overallRating, inInclusiveRange(1, 100));
      expect(team.fifaRanking, inInclusiveRange(1, 211));
    }
  });

  test('every confederation filter contains exactly its own teams', () {
    for (final entry in expectedConfederationSizes.entries) {
      final filtered = allNationalTeams
          .where((team) => team.continent == entry.key)
          .toList();

      expect(filtered, hasLength(entry.value));
      expect(filtered.every((team) => team.continent == entry.key), isTrue);
    }
  });

  test('career selection exposes every national team without divergence', () {
    expect(countries, hasLength(allNationalTeams.length));

    for (final team in allNationalTeams) {
      final country = countries.singleWhere((item) => item.id == team.id);
      expect(country.name, team.name);
      expect(country.continent, team.continent.displayName);
      expect(country.overallRating, team.overallRating);
    }
  });
}
