import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/goal.dart';
import '../models/goal_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;

  // In-memory fallback for Web preview
  final List<Goal> _webGoals = [];
  final Map<String, GoalRecord> _webRecords = {};
  bool _webInitialized = false;

  void _initWebSampleData() {
    if (_webInitialized) return;
    _webInitialized = true;
    final now = DateTime.now();
    _webGoals.addAll([
      Goal(
        id: 'g_1',
        title: 'Tập thể dục',
        description: '30 phút mỗi ngày',
        category: 'health',
        color: '#10B981',
        targetCount: 1,
        unit: 'buổi',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'fitness',
      ),
      Goal(
        id: 'g_2',
        title: 'Đọc sách',
        description: '30 phút mỗi ngày',
        category: 'study',
        color: '#2563EB',
        targetCount: 30,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'book',
      ),
      Goal(
        id: 'g_3',
        title: 'Uống đủ nước',
        description: '2 lít mỗi ngày',
        category: 'water',
        color: '#F59E0B',
        targetCount: 4,
        unit: 'ly nước',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'water',
      ),
      Goal(
        id: 'g_4',
        title: 'Thiền / Thư giãn',
        description: '10 phút mỗi ngày',
        category: 'mind',
        color: '#8B5CF6',
        targetCount: 10,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'yoga',
      ),
      Goal(
        id: 'g_5',
        title: 'Không ăn ngọt',
        description: 'Hạn chế đường và đồ ngọt',
        category: 'diet',
        color: '#EF4444',
        targetCount: 1,
        unit: 'ngày',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'food',
      ),
    ]);

    // Seed records for past 7 days so calendar dots and streaks show up
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      for (final g in _webGoals) {
        // Complete most habits to show nice progress
        final isDone = !(i == 0 && g.id == 'g_5'); // On today, 4 of 5 completed, or let's say all 5 completed
        _webRecords['${g.id}_$dateStr'] = GoalRecord(
          id: '${g.id}_$dateStr',
          goalId: g.id,
          date: dateStr,
          completed: isDone,
          currentCount: isDone ? g.targetCount : (g.targetCount ~/ 2),
          note: g.id == 'g_1' ? 'Tập hít đất và squat 30 phút buổi sáng' : '',
          updatedAt: d,
        );
      }
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/atomic_habit_native.db';

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE goals ADD COLUMN icon TEXT;');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        color TEXT NOT NULL,
        targetFrequency TEXT NOT NULL,
        weekdays TEXT NOT NULL,
        targetCount INTEGER NOT NULL,
        unit TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        icon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_records (
        id TEXT PRIMARY KEY,
        goalId TEXT NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL,
        currentCount INTEGER NOT NULL,
        note TEXT,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    await _seedSampleData(db);
  }

  Future<void> _seedSampleData(Database db) async {
    final now = DateTime.now();
    final sampleGoals = [
      Goal(
        id: 'g_1',
        title: 'Tập thể dục',
        description: '30 phút mỗi ngày',
        category: 'health',
        color: '#10B981',
        targetCount: 1,
        unit: 'buổi',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'fitness',
      ),
      Goal(
        id: 'g_2',
        title: 'Đọc sách',
        description: '30 phút mỗi ngày',
        category: 'study',
        color: '#2563EB',
        targetCount: 30,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'book',
      ),
      Goal(
        id: 'g_3',
        title: 'Uống đủ nước',
        description: '2 lít mỗi ngày',
        category: 'water',
        color: '#F59E0B',
        targetCount: 4,
        unit: 'ly nước',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'water',
      ),
      Goal(
        id: 'g_4',
        title: 'Thiền / Thư giãn',
        description: '10 phút mỗi ngày',
        category: 'mind',
        color: '#8B5CF6',
        targetCount: 10,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'yoga',
      ),
      Goal(
        id: 'g_5',
        title: 'Không ăn ngọt',
        description: 'Hạn chế đường và đồ ngọt',
        category: 'diet',
        color: '#EF4444',
        targetCount: 1,
        unit: 'ngày',
        createdAt: now.subtract(const Duration(days: 30)),
        icon: 'food',
      ),
    ];

    for (final goal in sampleGoals) {
      await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed records for past 7 days
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      for (final g in sampleGoals) {
        final isDone = !(i == 0 && g.id == 'g_5');
        final rec = GoalRecord(
          id: '${g.id}_$dateStr',
          goalId: g.id,
          date: dateStr,
          completed: isDone,
          currentCount: isDone ? g.targetCount : (g.targetCount ~/ 2),
          note: g.id == 'g_1' ? 'Tập hít đất và squat 30 phút buổi sáng' : '',
          updatedAt: d,
        );
        await db.insert('goal_records', rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  // --- Goals CRUD ---
  Future<List<Goal>> getAllGoals() async {
    if (kIsWeb) {
      _initWebSampleData();
      return List.unmodifiable(_webGoals);
    }
    final db = await database;
    final maps = await db.query('goals', orderBy: 'createdAt ASC');
    return maps.map((m) => Goal.fromMap(m)).toList();
  }

  Future<void> insertGoal(Goal goal) async {
    if (kIsWeb) {
      _initWebSampleData();
      _webGoals.removeWhere((g) => g.id == goal.id);
      _webGoals.add(goal);
      return;
    }
    final db = await database;
    await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoal(Goal goal) async {
    if (kIsWeb) {
      _initWebSampleData();
      final idx = _webGoals.indexWhere((g) => g.id == goal.id);
      if (idx != -1) {
        _webGoals[idx] = goal;
      }
      return;
    }
    final db = await database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(String id) async {
    if (kIsWeb) {
      _webGoals.removeWhere((g) => g.id == id);
      _webRecords.removeWhere((k, v) => v.goalId == id);
      return;
    }
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    await db.delete('goal_records', where: 'goalId = ?', whereArgs: [id]);
  }

  // --- Records CRUD ---
  Future<List<GoalRecord>> getAllRecords() async {
    if (kIsWeb) {
      return _webRecords.values.toList();
    }
    final db = await database;
    final maps = await db.query('goal_records');
    return maps.map((m) => GoalRecord.fromMap(m)).toList();
  }

  Future<GoalRecord?> getRecord(String goalId, String date) async {
    if (kIsWeb) {
      final key = '${goalId}_$date';
      return _webRecords[key];
    }
    final db = await database;
    final key = '${goalId}_$date';
    final maps = await db.query('goal_records', where: 'id = ?', whereArgs: [key], limit: 1);
    if (maps.isNotEmpty) {
      return GoalRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GoalRecord>> getRecordsForDate(String date) async {
    if (kIsWeb) {
      return _webRecords.values.where((r) => r.date == date).toList();
    }
    final db = await database;
    final maps = await db.query('goal_records', where: 'date = ?', whereArgs: [date]);
    return maps.map((m) => GoalRecord.fromMap(m)).toList();
  }

  Future<void> saveRecord(GoalRecord record) async {
    if (kIsWeb) {
      final key = '${record.goalId}_${record.date}';
      _webRecords[key] = record;
      return;
    }
    final db = await database;
    await db.insert('goal_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAllRecords() async {
    if (kIsWeb) {
      _webRecords.clear();
      return;
    }
    final db = await database;
    await db.delete('goal_records');
  }

  // --- Export / Import Backup ---
  Future<String> exportBackupJson() async {
    final goals = await getAllGoals();
    final records = await getAllRecords();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'records': records.map((r) => r.toMap()).toList(),
    };

    return jsonEncode(data);
  }

  Future<void> importBackupJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (kIsWeb) {
      if (data.containsKey('goals')) {
        final goalsList = data['goals'] as List<dynamic>;
        _webGoals.clear();
        for (final g in goalsList) {
          _webGoals.add(Goal.fromMap(g as Map<String, dynamic>));
        }
      }
      if (data.containsKey('records')) {
        final recordsList = data['records'] as List<dynamic>;
        _webRecords.clear();
        for (final r in recordsList) {
          final rec = GoalRecord.fromMap(r as Map<String, dynamic>);
          _webRecords['${rec.goalId}_${rec.date}'] = rec;
        }
      }
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      if (data.containsKey('goals')) {
        final goalsList = data['goals'] as List<dynamic>;
        for (final g in goalsList) {
          await txn.insert('goals', g as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (data.containsKey('records')) {
        final recordsList = data['records'] as List<dynamic>;
        for (final r in recordsList) {
          await txn.insert('goal_records', r as Map<String, dynamic>, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
