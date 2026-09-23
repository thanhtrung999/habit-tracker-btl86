import '../models/day_progress.dart';
import '../models/goal.dart';
import '../models/goal_record.dart';
import '../services/database_service.dart';
import '../../core/utils/date_utils.dart';

class HabitRepository {
  final DatabaseService _dbService;

  HabitRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Goal>> getGoals() async {
    return await _dbService.getAllGoals();
  }

  Future<void> addGoal(Goal goal) async {
    await _dbService.insertGoal(goal);
  }

  Future<void> updateGoal(Goal goal) async {
    await _dbService.updateGoal(goal);
  }

  Future<void> deleteGoal(String id) async {
    await _dbService.deleteGoal(id);
  }

  Future<GoalRecord?> getRecord(String goalId, String date) async {
    return await _dbService.getRecord(goalId, date);
  }

  Future<Map<String, GoalRecord>> getRecordsMapForDate(String date) async {
    final records = await _dbService.getRecordsForDate(date);
    return {for (var r in records) r.goalId: r};
  }

  Future<GoalRecord> toggleGoalCompletion({
    required Goal goal,
    required String date,
    bool? forcedState,
  }) async {
    final existing = await _dbService.getRecord(goal.id, date);
    final isCompleted = forcedState ?? !(existing?.completed ?? false);
    final count = isCompleted ? goal.targetCount : 0;

    final record = GoalRecord(
      id: '${goal.id}_$date',
      goalId: goal.id,
      date: date,
      completed: isCompleted,
      currentCount: count,
      note: existing?.note ?? '',
      updatedAt: DateTime.now(),
    );

    await _dbService.saveRecord(record);
    return record;
  }

  Future<GoalRecord> updateGoalCount({
    required Goal goal,
    required String date,
    required int delta,
  }) async {
    final existing = await _dbService.getRecord(goal.id, date);
    final current = existing?.currentCount ?? 0;
    final newCount = (current + delta).clamp(0, 9999);
    final isCompleted = newCount >= goal.targetCount;

    final record = GoalRecord(
      id: '${goal.id}_$date',
      goalId: goal.id,
      date: date,
      completed: isCompleted,
      currentCount: newCount,
      note: existing?.note ?? '',
      updatedAt: DateTime.now(),
    );

    await _dbService.saveRecord(record);
    return record;
  }

  Future<void> saveGoalNote({
    required String goalId,
    required String date,
    required String note,
  }) async {
    final existing = await _dbService.getRecord(goalId, date);
    final record = GoalRecord(
      id: '${goalId}_$date',
      goalId: goalId,
      date: date,
      completed: existing?.completed ?? false,
      currentCount: existing?.currentCount ?? 0,
      note: note.trim(),
      updatedAt: DateTime.now(),
    );
    await _dbService.saveRecord(record);
  }

  Future<DayProgress> getDayProgress(String dateStr) async {
    final goals = await _dbService.getAllGoals();
    final targetDate = AppDateUtils.parseDate(dateStr);
    final scheduledGoals = goals.where((g) => g.isScheduledForDate(targetDate)).toList();

    if (scheduledGoals.isEmpty) {
      return DayProgress(
        date: dateStr,
        total: 0,
        completed: 0,
        percent: 0,
      );
    }

    final records = await getRecordsMapForDate(dateStr);
    int completedCount = 0;
    for (final g in scheduledGoals) {
      final rec = records[g.id];
      if (rec != null && rec.completed) {
        completedCount++;
      }
    }

    final percent = ((completedCount / scheduledGoals.length) * 100).round();

    return DayProgress(
      date: dateStr,
      total: scheduledGoals.length,
      completed: completedCount,
      percent: percent,
    );
  }

  Future<int> calculateOverallStreak() async {
    final goals = await _dbService.getAllGoals();
    if (goals.isEmpty) return 0;

    final allRecords = await _dbService.getAllRecords();
    final recordsMap = {for (var r in allRecords) '${r.goalId}_${r.date}': r};

    int streak = 0;
    final now = DateTime.now();

    for (int offset = 0; offset < 365; offset++) {
      final checkDate = now.subtract(Duration(days: offset));
      final dateStr = AppDateUtils.formatDate(checkDate);

      final scheduledGoals = goals.where((g) => g.isScheduledForDate(checkDate)).toList();
      if (scheduledGoals.isEmpty) continue;

      int completed = 0;
      for (final g in scheduledGoals) {
        final rec = recordsMap['${g.id}_$dateStr'];
        if (rec != null && rec.completed) completed++;
      }

      final rate = completed / scheduledGoals.length;

      // Allow today to be incomplete without breaking streak
      if (offset == 0 && rate < 0.5) {
        continue;
      }

      if (rate >= 0.5) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<int> getGoalStreak(String goalId) async {
    final goals = await _dbService.getAllGoals();
    final goalMatches = goals.where((g) => g.id == goalId);
    if (goalMatches.isEmpty) return 0;
    final goal = goalMatches.first;

    final allRecords = await _dbService.getAllRecords();
    final recordsMap = {
      for (var r in allRecords.where((r) => r.goalId == goalId)) r.date: r
    };

    final now = DateTime.now();
    final todayStr = AppDateUtils.formatDate(now);
    final isTodayScheduled = goal.isScheduledForDate(now);
    final todayRec = recordsMap[todayStr];

    int streak = 0;
    int offset = 0;

    if (isTodayScheduled && todayRec != null && todayRec.completed) {
      streak = 1;
      offset = 1;
    } else {
      offset = 1;
    }

    while (offset < 365) {
      final checkDate = now.subtract(Duration(days: offset));
      final dateStr = AppDateUtils.formatDate(checkDate);

      if (!goal.isScheduledForDate(checkDate)) {
        offset++;
        continue;
      }

      final rec = recordsMap[dateStr];
      if (rec != null && rec.completed) {
        streak++;
        offset++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<Map<String, int>> getAllGoalStreaks() async {
    final goals = await _dbService.getAllGoals();
    final Map<String, int> result = {};
    for (final g in goals) {
      result[g.id] = await getGoalStreak(g.id);
    }
    return result;
  }

  Future<List<DayProgress>> getWeeklyProgress(DateTime endOfWeekDate) async {
    final List<DayProgress> list = [];
    for (int i = 6; i >= 0; i--) {
      final date = endOfWeekDate.subtract(Duration(days: i));
      final dateStr = AppDateUtils.formatDate(date);
      final progress = await getDayProgress(dateStr);
      list.add(progress);
    }
    return list;
  }

  Future<Map<String, DayProgress>> getMonthProgress(int year, int month) async {
    final daysInMonth = AppDateUtils.getDaysInMonth(year, month);
    final Map<String, DayProgress> result = {};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = AppDateUtils.formatDate(date);
      result[dateStr] = await getDayProgress(dateStr);
    }

    return result;
  }

  Future<String> exportBackup() async {
    return await _dbService.exportBackupJson();
  }

  Future<void> importBackup(String json) async {
    await _dbService.importBackupJson(json);
  }
}
