class DayProgress {
  final String date;
  final int total;
  final int completed;
  final int percent;

  const DayProgress({
    required this.date,
    required this.total,
    required this.completed,
    required this.percent,
  });

  bool get isPerfect => total > 0 && percent == 100;
  bool get isPartial => total > 0 && percent > 0 && percent < 100;
  bool get isEmpty => percent == 0;
}
