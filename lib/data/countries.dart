import '../models/continent_type.dart';
import '../models/country.dart';
import 'national_teams.dart';

/// Career-selection projection of the canonical national-team database.
final List<Country> countries = List.unmodifiable(
  allNationalTeams.map(
    (team) => Country(
      id: team.id,
      name: team.name,
      flag: team.flag,
      continent: team.continent.displayName,
      overallRating: team.overallRating,
    ),
  ),
);
