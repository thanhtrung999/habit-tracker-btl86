import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/milestone_tiers.dart';
import '../../core/theme/app_colors.dart';
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
  Map<String, GoalRecord> _allRecordsMap = {};
  Map<String, int> _streaks = {};
  int _overallStreak = 0;
  DayProgress _dayProgress = const DayProgress(date: '', total: 0, completed: 0, percent: 0);
  List<DayProgress> _weeklyProgress = [];
  Map<String, DayProgress> _monthProgress = {};

  bool _isLoading = false;
  bool _justReachedPerfect = false;
  bool _isDarkMode = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateStr => AppDateUtils.formatDate(_selectedDate);
  DateTime get calendarMonth => _calendarMonth;
  List<Goal> get goals => _goals;
  Map<String, GoalRecord> get records => _records;
  Map<String, int> get streaks => _streaks;
  int get overallStreak => _overallStreak;
  int get currentStreak => _overallStreak;
  int get bestStreak {
    int best = _overallStreak;
    for (final s in _streaks.values) {
      if (s > best) best = s;
    }
    return best;
  }
  MilestoneTier get currentTier => MilestoneConstants.getTier(_overallStreak);
  DayProgress get dayProgress => _dayProgress;
  List<DayProgress> get weeklyProgress => _weeklyProgress;
  Map<String, DayProgress> get monthProgress => _monthProgress;
  bool get isLoading => _isLoading;
  bool get justReachedPerfect => _justReachedPerfect;

  /// Returns scheduled goals for selected date in their original order.
  /// Tasks stay in their exact position upon completion.
  List<Goal> get scheduledGoals {
    return _goals.where((g) => g.isScheduledForDate(_selectedDate)).toList();
  }

  GoalRecord? getRecordForGoal(String goalId) => _records[goalId];
  int getStreakForGoal(String goalId) => _streaks[goalId] ?? 0;
  bool isGoalCompleted(Goal goal) => _records[goal.id]?.completed ?? false;

  Map<String, GoalRecord> get allRecordsMap => _allRecordsMap;

  Future<void> init() async {
    _selectedDate = DateTime.now();
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      AppColors.isDark = _isDarkMode;
    } catch (_) {}
    await _refreshAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    AppColors.isDark = _isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (_) {}
  }

  /// Returns the maximum historical streak achieved by a specific goal.
  int getGoalBestStreak(String goalId) {
    final current = getStreakForGoal(goalId);
    final goalMatches = _goals.where((g) => g.id == goalId);
    if (goalMatches.isEmpty) return current;
    final goal = goalMatches.first;

    final completedDates = <DateTime>{};
    for (final entry in _allRecordsMap.values) {
      if (entry.goalId == goalId && entry.completed) {
        final parsed = AppDateUtils.parseDate(entry.date);
        completedDates.add(DateTime(parsed.year, parsed.month, parsed.day));
      }
    }
    if (completedDates.isEmpty) return current;

    final sortedDates = completedDates.toList()..sort();
    int best = current;
    int run = 0;
    DateTime? prev;

    for (final d in sortedDates) {
      if (prev == null) {
        run = 1;
      } else {
        final diff = d.difference(prev).inDays;
        if (diff == 1) {
          run++;
        } else if (diff == 0) {
          // duplicate / same day
        } else {
          bool allInterveningNotScheduled = true;
          for (int i = 1; i < diff; i++) {
            final inter = prev.add(Duration(days: i));
            if (goal.isScheduledForDate(inter)) {
              allInterveningNotScheduled = false;
              break;
            }
          }
          if (allInterveningNotScheduled) {
            run++;
          } else {
            run = 1;
          }
        }
      }
      prev = d;
      if (run > best) best = run;
    }

    return best;
  }

  /// Returns sub-habits (goals) that have reached a given milestone tier.
  List<Goal> getGoalsForMilestone(MilestoneTier tier) {
    final requiredDays = tier.minDays == 0 ? 1 : tier.minDays;
    return _goals.where((g) {
      final best = getGoalBestStreak(g.id);
      return best >= requiredDays;
    }).toList();
  }

  void syncTodayDate() {
    final now = DateTime.now();
    if (AppDateUtils.formatDate(now) != selectedDateStr) {
      selectDate(now);
    }
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    _records = await _repository.getRecordsMapForDate(selectedDateStr);
    _allRecordsMap = await _repository.getAllRecordsMap();
    _streaks = await _repository.getAllGoalStreaks(_selectedDate);
    _overallStreak = await _repository.calculateOverallStreak(_selectedDate);
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
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
    _allRecordsMap = await _repository.getAllRecordsMap();
    _streaks = await _repository.getAllGoalStreaks(_selectedDate);
    _overallStreak = await _repository.calculateOverallStreak(_selectedDate);
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _weeklyProgress = await _repository.getWeeklyProgress(_selectedDate);
    _monthProgress = await _repository.getMonthProgress(_calendarMonth.year, _calendarMonth.month);
  }

  void resetConfetti() {
    _justReachedPerfect = false;
  }

  Future<void> toggleGoal(Goal goal) async {
    final wasCompleted = _records[goal.id]?.completed ?? false;
    final nowCompleted = !wasCompleted;

    // 1. Optimistic in-memory update IMMEDIATELY so top progress ring and UI react at frame 0
    final currentCount = nowCompleted ? goal.targetCount : 0;
    _records[goal.id] = GoalRecord(
      id: '${goal.id}_$selectedDateStr',
      goalId: goal.id,
      date: selectedDateStr,
      completed: nowCompleted,
      currentCount: currentCount,
      note: _records[goal.id]?.note ?? '',
      updatedAt: DateTime.now(),
    );

    final scheduled = scheduledGoals;
    int completedCount = 0;
    for (final g in scheduled) {
      if (_records[g.id]?.completed == true) completedCount++;
    }
    _dayProgress = DayProgress(
      date: selectedDateStr,
      total: scheduled.length,
      completed: completedCount,
      percent: scheduled.isEmpty ? 0 : ((completedCount / scheduled.length) * 100).round(),
    );

    if (nowCompleted) {
      _streaks[goal.id] = (_streaks[goal.id] ?? 0) + 1;
      if (completedCount == scheduled.length && scheduled.isNotEmpty && AppDateUtils.isToday(selectedDateStr)) {
        _overallStreak += 1;
      }
    } else {
      _streaks[goal.id] = ((_streaks[goal.id] ?? 1) - 1).clamp(0, 9999);
      if (completedCount == scheduled.length - 1 && scheduled.isNotEmpty && AppDateUtils.isToday(selectedDateStr)) {
        _overallStreak = (_overallStreak > 0 ? _overallStreak - 1 : 0);
      }
    }

    _allRecordsMap['${goal.id}_$selectedDateStr'] = _records[goal.id]!;
    notifyListeners();

    // 2. Persist to database in background
    final updatedRecord = await _repository.toggleGoalCompletion(
      goal: goal,
      date: selectedDateStr,
      forcedState: nowCompleted,
    );

    _records[goal.id] = updatedRecord;
    _allRecordsMap[updatedRecord.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id, _selectedDate);
    _overallStreak = await _repository.calculateOverallStreak(_selectedDate);
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
    _allRecordsMap[updatedRecord.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id, _selectedDate);
    _overallStreak = await _repository.calculateOverallStreak(_selectedDate);
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
    _allRecordsMap[updatedRecord.id] = updatedRecord;
    _dayProgress = await _repository.getDayProgress(selectedDateStr);
    _streaks[goal.id] = await _repository.getGoalStreak(goal.id, _selectedDate);
    _overallStreak = await _repository.calculateOverallStreak(_selectedDate);
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

  Future<void> resetAllProgress() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.clearAllRecords();
      await _refreshAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
