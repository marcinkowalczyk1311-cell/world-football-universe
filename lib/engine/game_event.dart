abstract class GameEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  void execute();

  void log() {
    print("[$id] $title");
    print(description);
  }

  @override
  String toString() {
    return "$title ($date)";
  }
}