import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'practice_progress.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE practice_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        subjectName TEXT NOT NULL,
        questionIndex INTEGER NOT NULL,
        userAnswer INTEGER,
        userAnswers TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        UNIQUE(userId, subjectName)
      )
    ''');

    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectName TEXT,
        questionIndex INTEGER,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectName TEXT,
        examId TEXT,
        score INTEGER,
        totalQuestions INTEGER,
        duration INTEGER,
        date TEXT,
        questions TEXT,
        answers TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE practice_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectName TEXT NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        answers TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveProgress({
    required String subjectName,
    required int questionIndex,
    required int? userAnswer,
    String? userAnswers,
    bool isCompleted = false,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final db = await database;
    await db.insert('practice_progress', {
      'userId': userId,
      'subjectName': subjectName,
      'questionIndex': questionIndex,
      'userAnswer': userAnswer,
      'userAnswers': userAnswers,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getProgress(String subjectName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_progress',
      where: 'userId = ? AND subjectName = ?',
      whereArgs: [userId, subjectName],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> deleteProgress(String subjectName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final db = await database;

      // First check if the record exists
      final List<Map<String, dynamic>> records = await db.query(
        'practice_progress',
        where: 'userId = ? AND subjectName = ?',
        whereArgs: [userId, subjectName],
      );

      if (records.isNotEmpty) {
        // Try to delete the record
        final deleted = await db.delete(
          'practice_progress',
          where: 'userId = ? AND subjectName = ?',
          whereArgs: [userId, subjectName],
        );

        if (deleted == 0) {
          // If delete failed, try to update instead
          await db.update(
            'practice_progress',
            {
              'isCompleted': 1,
              'questionIndex': 0,
              'userAnswer': null,
              'userAnswers': null,
              'createdAt': DateTime.now().toIso8601String(),
            },
            where: 'userId = ? AND subjectName = ?',
            whereArgs: [userId, subjectName],
          );
        }
      }

      // Verify deletion/update
      final remainingRecords = await db.query(
        'practice_progress',
        where: 'userId = ? AND subjectName = ?',
        whereArgs: [userId, subjectName],
      );

      if (remainingRecords.isNotEmpty) {
        print('Warning: Progress record still exists after deletion attempt');
      }
    } catch (e) {
      print('Error in deleteProgress: $e');
      // If there's an error, try to close and reopen the database
      try {
        if (_database != null) {
          await _database!.close();
          _database = null;
        }
      } catch (e) {
        print('Error closing database: $e');
      }
      rethrow; // Rethrow to handle in the calling code
    }
  }

  Future<void> saveQuizHistory({
    required String subjectName,
    required String examId,
    required int score,
    required int totalQuestions,
    required int duration,
    required List<Map<String, dynamic>> questions,
    required List<int?> answers,
  }) async {
    final db = await database;
    await db.insert('quiz_history', {
      'subjectName': subjectName,
      'examId': examId,
      'score': score,
      'totalQuestions': totalQuestions,
      'duration': duration,
      'date': DateTime.now().toIso8601String(),
      'questions': jsonEncode(questions),
      'answers': jsonEncode(answers),
    });
  }

  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_history',
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      final questions =
          (jsonDecode(map['questions'] as String) as List)
              .map((q) => Map<String, dynamic>.from(q))
              .toList();
      final answers =
          (jsonDecode(map['answers'] as String) as List)
              .map((a) => a == null ? null : a as int)
              .toList();

      return {...map, 'questions': questions, 'answers': answers};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getQuizHistoryBySubject(
    String subjectName,
  ) async {
    final db = await database;
    return await db.query(
      'quiz_history',
      where: 'subjectName = ?',
      whereArgs: [subjectName],
      orderBy: 'date DESC',
    );
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'practice_progress.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future<List<Map<String, dynamic>>> getPracticeHistory() async {
    final db = await database;
    return await db.query('practice_history', orderBy: 'date DESC');
  }

  Future<void> deleteQuizHistory(int id) async {
    final db = await database;
    await db.delete('quiz_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePracticeHistory(int id) async {
    final db = await database;
    await db.delete('practice_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> savePracticeHistory({
    required String subjectName,
    required int score,
    required int totalQuestions,
    required Duration duration,
    required List<int?> answers,
  }) async {
    final db = await database;
    await db.insert('practice_history', {
      'subjectName': subjectName,
      'score': score,
      'totalQuestions': totalQuestions,
      'duration': duration.inSeconds,
      'answers': answers.toString(),
      'date': DateTime.now().toIso8601String(),
    });
  }
}
