import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/goal.dart';
import '../models/goal_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // If running on desktop (macOS/Windows/Linux), initialize FFI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'habit_tracker_native.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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
        createdAt TEXT NOT NULL
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
        title: 'Uống đủ 2 lít nước',
        description: 'Giữ cơ thể luôn đủ nước và thanh lọc mỗi ngày',
        category: 'health',
        color: '#3B82F6',
        targetCount: 4,
        unit: 'ly nước',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Goal(
        id: 'g_2',
        title: 'Đọc sách 20 phút',
        description: 'Phát triển bản thân và nâng cao kiến thức',
        category: 'study',
        color: '#10B981',
        targetCount: 20,
        unit: 'phút',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Goal(
        id: 'g_3',
        title: 'Tập thể dục / Yoga',
        description: 'Vận động thể chất ít nhất 30 phút mỗi ngày',
        category: 'health',
        color: '#F59E0B',
        targetCount: 1,
        unit: 'buổi',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Goal(
        id: 'g_4',
        title: 'Viết nhật ký biết ơn',
        description: 'Ghi lại 3 điều tích cực đã xảy ra trong ngày',
        category: 'mind',
        color: '#8B5CF6',
        targetCount: 1,
        unit: 'lần',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];

    for (final goal in sampleGoals) {
      await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- Goals CRUD ---
  Future<List<Goal>> getAllGoals() async {
    final db = await database;
    final maps = await db.query('goals', orderBy: 'createdAt ASC');
    return maps.map((m) => Goal.fromMap(m)).toList();
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    await db.delete('goal_records', where: 'goalId = ?', whereArgs: [id]);
  }

  // --- Records CRUD ---
  Future<List<GoalRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('goal_records');
    return maps.map((m) => GoalRecord.fromMap(m)).toList();
  }

  Future<GoalRecord?> getRecord(String goalId, String date) async {
    final db = await database;
    final key = '${goalId}_$date';
    final maps = await db.query('goal_records', where: 'id = ?', whereArgs: [key], limit: 1);
    if (maps.isNotEmpty) {
      return GoalRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GoalRecord>> getRecordsForDate(String date) async {
    final db = await database;
    final maps = await db.query('goal_records', where: 'date = ?', whereArgs: [date]);
    return maps.map((m) => GoalRecord.fromMap(m)).toList();
  }

  Future<void> saveRecord(GoalRecord record) async {
    final db = await database;
    await db.insert('goal_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
