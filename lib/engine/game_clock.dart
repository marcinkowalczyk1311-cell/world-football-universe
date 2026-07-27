class GameClock {
  DateTime _currentDate = DateTime(2026, 7, 1);

  DateTime get currentDate => _currentDate;

  void nextDay() {
    _currentDate = _currentDate.add(
      const Duration(days: 1),
    );
  }

  void reset() {
    _currentDate = DateTime(2026, 7, 1);
  }
}