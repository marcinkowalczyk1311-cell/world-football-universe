import 'competition_type.dart';

class Competition {
  final String id;
  final String name;
  final String shortName;
  final CompetitionType type;

  const Competition({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
  });

  @override
  String toString() => name;
}