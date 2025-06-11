import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/time_exam.dart';

class TimeExamDatabase {
  static final TimeExamDatabase instance = TimeExamDatabase._init();
  static Database? _database;

  TimeExamDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('time_exams.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        examDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> createTimeExam(TimeExam timeExam) async {
    final db = await instance.database;
    return await db.insert('time_exams', timeExam.toMap());
  }

  Future<List<TimeExam>> getAllTimeExams() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('time_exams');
    return List.generate(maps.length, (i) => TimeExam.fromMap(maps[i]));
  }

  Future<TimeExam?> getTimeExam(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_exams',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TimeExam.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTimeExam(TimeExam timeExam) async {
    final db = await instance.database;
    return await db.update(
      'time_exams',
      timeExam.toMap(),
      where: 'id = ?',
      whereArgs: [timeExam.id],
    );
  }

  Future<int> deleteTimeExam(int id) async {
    final db = await instance.database;
    return await db.delete('time_exams', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
