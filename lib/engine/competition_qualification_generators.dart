import '../models/competition.dart';
import '../models/competition_type.dart';
import '../models/continent_type.dart';
import '../models/national_team.dart';
import '../models/qualification_group.dart';
import '../models/qualification_state.dart';
import '../models/tournament.dart';
import 'match.dart';
import 'qualification_schedule_generator.dart';

abstract class CompetitionQualificationGenerator {
  const CompetitionQualificationGenerator();

  String get tournamentId;
  int groupCount(ContinentType confederation, int teamCount);
  int advancingPerGroup(ContinentType confederation);

  QualificationState generate({
    required TournamentDefinition tournament,
    required List<NationalTeam> teams,
    required ContinentType confederation,
    required NationalTeam playerTeam,
    required DateTime startDate,
    required int finalsYear,
  }) {
    if (tournament.id != tournamentId) {
      throw ArgumentError('$runtimeType cannot generate ${tournament.id}.');
    }
    final eligible =
        teams.where((team) => team.continent == confederation).toList()
          ..sort((a, b) => a.fifaRanking.compareTo(b.fifaRanking));
    final ids = eligible.map((team) => team.id).toList();
    if (playerTeam.continent != confederation || !ids.contains(playerTeam.id)) {
      throw ArgumentError('The player team is not in the eligible team pool.');
    }
    if (ids.toSet().length != ids.length) {
      throw ArgumentError('The eligible team pool contains duplicate teams.');
    }

    final count = groupCount(confederation, eligible.length);
    if (count < 1 || count > eligible.length ~/ 2) {
      throw StateError('Invalid group count for $tournamentId.');
    }
    final buckets = List.generate(count, (_) => <NationalTeam>[]);
    for (var index = 0; index < eligible.length; index++) {
      final row = index ~/ count;
      final column = index % count;
      buckets[row.isEven ? column : count - 1 - column].add(eligible[index]);
    }
    final playerIndex = buckets.indexWhere(
      (bucket) => bucket.any((team) => team.id == playerTeam.id),
    );
    final ordered = [
      buckets[playerIndex],
      for (var index = 0; index < buckets.length; index++)
        if (index != playerIndex) buckets[index],
    ];
    final groups = List.generate(
      ordered.length,
      (index) => QualificationGroup(
        name: String.fromCharCode(65 + index),
        teams: List.unmodifiable(ordered[index]),
        advancingTeamCount: advancingPerGroup(
          confederation,
        ).clamp(1, ordered[index].length - 1),
      ),
      growable: false,
    );
    _validateGroups(groups, eligible, count);

    final competition = Competition(
      id: '${tournament.id}_QUALIFICATION',
      name: '${tournament.name} Qualification',
      shortName: '${tournament.shortName} Qual.',
      type: tournament.id == 'FIFA_WORLD_CUP'
          ? CompetitionType.worldCupQualifiers
          : CompetitionType.continentalQualifiers,
    );
    final editionId = '${tournament.id}_$finalsYear';
    final fixtures = <Match>[];
    for (var index = 0; index < groups.length; index++) {
      final generated = QualificationScheduleGenerator().generate(
        groups[index],
        startDate: startDate.add(Duration(days: index)),
        competition: competition,
        tournamentEditionId: editionId,
      );
      QualificationScheduleGenerator.validate(groups[index], generated);
      fixtures.addAll(generated);
    }
    return QualificationState(
      competition: competition,
      editionId: editionId,
      groups: List.unmodifiable(groups),
      fixtures: List.unmodifiable(fixtures),
    );
  }

  void _validateGroups(
    List<QualificationGroup> groups,
    List<NationalTeam> eligible,
    int expectedCount,
  ) {
    final assigned = groups.expand((group) => group.teams).toList();
    if (groups.length != expectedCount ||
        assigned.length != eligible.length ||
        assigned.map((team) => team.id).toSet().length != eligible.length) {
      throw StateError('Every eligible team must appear exactly once.');
    }
    final minSize = eligible.length ~/ expectedCount;
    final maxSize = (eligible.length / expectedCount).ceil();
    if (groups.any(
      (group) => group.teams.length < minSize || group.teams.length > maxSize,
    )) {
      throw StateError('Qualification group sizes are invalid.');
    }
  }
}

class WorldCupQualificationGenerator extends CompetitionQualificationGenerator {
  const WorldCupQualificationGenerator();
  @override
  String get tournamentId => 'FIFA_WORLD_CUP';
  @override
  int groupCount(ContinentType confederation, int teamCount) =>
      switch (confederation) {
        ContinentType.europe => 12,
        ContinentType.southAmerica => 1,
        ContinentType.northAmerica => 6,
        ContinentType.africa => 9,
        ContinentType.asia => 9,
        ContinentType.oceania => 3,
      };
  @override
  int advancingPerGroup(ContinentType confederation) =>
      confederation == ContinentType.southAmerica ? 6 : 1;
}

abstract class ContinentalQualificationGenerator
    extends CompetitionQualificationGenerator {
  final String id;
  final int groups;
  final int advancing;
  const ContinentalQualificationGenerator(this.id, this.groups, this.advancing);
  @override
  String get tournamentId => id;
  @override
  int groupCount(ContinentType confederation, int teamCount) =>
      groups.clamp(1, teamCount ~/ 2);
  @override
  int advancingPerGroup(ContinentType confederation) => advancing;
}

class EuroQualificationGenerator extends ContinentalQualificationGenerator {
  const EuroQualificationGenerator() : super('UEFA_EURO', 10, 2);
}

class CopaAmericaQualificationGenerator
    extends ContinentalQualificationGenerator {
  const CopaAmericaQualificationGenerator() : super('COPA_AMERICA', 1, 6);
}

class AsianCupQualificationGenerator extends ContinentalQualificationGenerator {
  const AsianCupQualificationGenerator() : super('AFC_ASIAN_CUP', 8, 3);
}

class AfconQualificationGenerator extends ContinentalQualificationGenerator {
  const AfconQualificationGenerator() : super('AFRICA_CUP_OF_NATIONS', 9, 2);
}

class GoldCupQualificationGenerator extends ContinentalQualificationGenerator {
  const GoldCupQualificationGenerator() : super('CONCACAF_GOLD_CUP', 6, 2);
}

class OfcNationsCupQualificationGenerator
    extends ContinentalQualificationGenerator {
  const OfcNationsCupQualificationGenerator() : super('OFC_NATIONS_CUP', 3, 2);
}

class QualificationGeneratorRegistry {
  static const Map<String, CompetitionQualificationGenerator> generators = {
    'FIFA_WORLD_CUP': WorldCupQualificationGenerator(),
    'UEFA_EURO': EuroQualificationGenerator(),
    'COPA_AMERICA': CopaAmericaQualificationGenerator(),
    'AFC_ASIAN_CUP': AsianCupQualificationGenerator(),
    'AFRICA_CUP_OF_NATIONS': AfconQualificationGenerator(),
    'CONCACAF_GOLD_CUP': GoldCupQualificationGenerator(),
    'OFC_NATIONS_CUP': OfcNationsCupQualificationGenerator(),
  };

  static CompetitionQualificationGenerator forTournament(String id) {
    final generator = generators[id];
    if (generator == null) {
      throw StateError('No qualification generator registered for $id.');
    }
    return generator;
  }
}
