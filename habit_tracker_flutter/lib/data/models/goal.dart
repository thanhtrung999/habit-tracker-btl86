class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String color;
  final String targetFrequency;
  final List<int> weekdays;
  final int targetCount;
  final String unit;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'health',
    this.color = '#2D6A4F',
    this.targetFrequency = 'all',
    this.weekdays = const [0, 1, 2, 3, 4, 5, 6],
    this.targetCount = 1,
    this.unit = 'lần',
    required this.createdAt,
  });

  bool isScheduledForDate(DateTime date) {
    if (targetFrequency == 'all') return true;
    final dayOfWeek = date.weekday % 7; // 0: Sun, 1: Mon...
    return weekdays.contains(dayOfWeek);
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? color,
    String? targetFrequency,
    List<int>? weekdays,
    int? targetCount,
    String? unit,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      weekdays: weekdays ?? this.weekdays,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color': color,
      'targetFrequency': targetFrequency,
      'weekdays': weekdays.join(','),
      'targetCount': targetCount,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    final weekdaysRaw = (map['weekdays'] as String?) ?? '0,1,2,3,4,5,6';
    final weekdaysParsed = weekdaysRaw.isEmpty
        ? <int>[0, 1, 2, 3, 4, 5, 6]
        : weekdaysRaw.split(',').map((e) => int.tryParse(e) ?? 0).toList();

    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'health',
      color: (map['color'] as String?) ?? '#2D6A4F',
      targetFrequency: (map['targetFrequency'] as String?) ?? 'all',
      weekdays: weekdaysParsed,
      targetCount: (map['targetCount'] as int?) ?? 1,
      unit: (map['unit'] as String?) ?? 'lần',
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}
