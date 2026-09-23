class GoalRecord {
  final String id; // format: ${goalId}_${date}
  final String goalId;
  final String date;
  final bool completed;
  final int currentCount;
  final String note;
  final DateTime updatedAt;

  const GoalRecord({
    required this.id,
    required this.goalId,
    required this.date,
    this.completed = false,
    this.currentCount = 0,
    this.note = '',
    required this.updatedAt,
  });

  GoalRecord copyWith({
    String? id,
    String? goalId,
    String? date,
    bool? completed,
    int? currentCount,
    String? note,
    DateTime? updatedAt,
  }) {
    return GoalRecord(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      currentCount: currentCount ?? this.currentCount,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'date': date,
      'completed': completed ? 1 : 0,
      'currentCount': currentCount,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GoalRecord.fromMap(Map<String, dynamic> map) {
    return GoalRecord(
      id: map['id'] as String,
      goalId: map['goalId'] as String,
      date: map['date'] as String,
      completed: (map['completed'] as int?) == 1,
      currentCount: (map['currentCount'] as int?) ?? 0,
      note: (map['note'] as String?) ?? '',
      updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}
