import 'package:flutter/foundation.dart';
import '../../core/constants/milestone_tiers.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/day_progress.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_record.dart';
import '../../data/repositories/habit_repository.dart';

class HabitViewModel extends ChangeNotifier {
  final HabitRepository _repository;

  HabitViewModel({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  DateTime _selectedDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();

  List<Goal> _goals = [];
  Map<String, GoalRecord> _records = {};
  Map<String, int> _streaks = {};
  int _overallStreak = 0;
  DayProgress _dayProgress = const DayProgress(date: '', total: 0, completed: 0, percent: 0);
  List<DayProgress> _weeklyProgress = [];
  Map<String, DayProgress> _monthProgress = {};

  bool _isLoading = false;
  bool _justReachedPerfect = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  String get selectedDateStr => AppDateUtils.formatDate(_selectedDate);
  DateTime get calendarMonth => _calendarMonth;
  List<Goal> get goals => _goals;
  Map<String, GoalRecord> get records => _records;
  Map<String, int> get streaks => _streaks;
  int get overallStreak => _overallStreak;
  MilestoneTier get currentTier => MilestoneConstants.getTier(_overallStreak);
  DayProgress get dayProgress => _dayProgress;
  List<DayProgress> get weeklyProgress => _weeklyProgress;
  Map<String, DayProgress> get monthProgress => _monthProgress;
  bool get isLoading => _isLoading;
  bool get justReachedPerfect => _justReachedPerfect;

  /// Returns scheduled goals for selected date,
  /// with uncompleted habits first and completed habits sorted to the bottom.
  List<Goal> get scheduledGoals {
    final scheduled = _goals.where((g) => g.isScheduledForDate(_selectedDate)).toList();
    scheduled.sort((a, b) {
      final aCompleted = _records[a.id]?.completed ?? false;
      final bCompleted = _records[b.id]?.completed ?? false;
      if (aCompleted == bCompleted) return 0;
      return aCompleted ? 1 : -1;
    });
    return scheduled;
  }

  GoalRecord? getRecordForGoal(String goalId) => _records[goalId];
  int getStreakForGoal(String goalId) => _streaks[goalId] ?? 0;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await _refreshAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    _records = await _repository.getRecordsMapForDate(selectedDateStr);
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    notifyListeners();
  }

  void changeCalendarMonth(int deltaMonths) {
    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + deltaMonths, 1);
    _loadMonthProgress();
  }

  Future<void> _loadMonthProgress() async {
    _monthProgress = await _repository.getMonthProgress(_calendarMonth.year, _calendarMonth.month);
    notifyListeners();
  }

  Future<void> _refreshAll() async {
    _goals = await _repository.getGoals();
    _records = await _repository.getRecordsMapForDate(selectedDateStr);
    _streaks = await _repository.getAllGoalStreaks();
    _overallStreak = await _repository.calculateOverallStreak();
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
    _monthProgress = await _repository.getMonthProgress(_calendarMonth.year, _calendarMonth.month);
  }

  void resetConfetti() {
    _justReachedPerfect = false;
  }

  Future<void> toggleGoal(Goal goal) async {
    final wasCompleted = _records[goal.id]?.completed ?? false;
    final updatedRecord = await _repository.toggleGoalCompletion(
      goal: goal,
      date: selectedDateStr,
    );

    _records[goal.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id);
    _overallStreak = await _repository.calculateOverallStreak();
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
    _monthProgress[selectedDateStr] = _dayProgress;

    // Trigger celebration if newly reached 100% on today
    if (!wasCompleted && _dayProgress.isPerfect && AppDateUtils.isToday(selectedDateStr)) {
      _justReachedPerfect = true;
    }

    notifyListeners();
  }

  Future<void> incrementGoal(Goal goal) async {
    final updatedRecord = await _repository.updateGoalCount(
      goal: goal,
      date: selectedDateStr,
      delta: 1,
    );

    _records[goal.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id);
    _overallStreak = await _repository.calculateOverallStreak();
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
    _monthProgress[selectedDateStr] = _dayProgress;

    if (_dayProgress.isPerfect && AppDateUtils.isToday(selectedDateStr)) {
      _justReachedPerfect = true;
    }

    notifyListeners();
  }

  Future<void> decrementGoal(Goal goal) async {
    final updatedRecord = await _repository.updateGoalCount(
      goal: goal,
      date: selectedDateStr,
      delta: -1,
    );

    _records[goal.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id);
    _overallStreak = await _repository.calculateOverallStreak();
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
    _monthProgress[selectedDateStr] = _dayProgress;

    notifyListeners();
  }

  Future<void> saveNote(String goalId, String note) async {
    await _repository.saveGoalNote(
      goalId: goalId,
      date: selectedDateStr,
      note: note,
    );
    _records = await _repository.getRecordsMapForDate(selectedDateStr);
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await _repository.addGoal(goal);
    await _refreshAll();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.updateGoal(goal);
    await _refreshAll();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await _refreshAll();
    notifyListeners();
  }

  Future<String> exportBackup() async {
    return await _repository.exportBackup();
  }

  Future<void> importBackup(String json) async {
    await _repository.importBackup(json);
    await _refreshAll();
    notifyListeners();
  }
}
