import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/question.dart';
import '../models/progress.dart';

class OfflineDatabaseService {
  static final OfflineDatabaseService _instance = OfflineDatabaseService._internal();
  factory OfflineDatabaseService() => _instance;
  OfflineDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'physics_book_offline_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY,
        bookId INTEGER,
        title TEXT,
        description TEXT,
        orderIndex INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY,
        chapterId INTEGER,
        title TEXT,
        orderIndex INTEGER,
        estimatedMinutes INTEGER,
        contentBody TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        lessonId INTEGER,
        questionText TEXT,
        optionA TEXT,
        optionB TEXT,
        optionC TEXT,
        optionD TEXT,
        correctOption TEXT,
        explanation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        lessonId INTEGER,
        isCompleted INTEGER,
        quizScore REAL,
        completionPercent REAL,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        lessonId INTEGER,
        type TEXT,
        payload TEXT,
        createdAt TEXT
      )
    ''');
  }

  // Chapters CRUD
  Future<void> saveChapters(List<Chapter> chapters) async {
    final db = await database;
    final batch = db.batch();
    for (final chapter in chapters) {
      batch.insert(
        'chapters',
        chapter.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Chapter>> getChapters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chapters', orderBy: 'orderIndex');
    return maps.map((map) => Chapter.fromJson(map)).toList();
  }

  // Lessons CRUD
  Future<void> saveLessons(List<Lesson> lessons) async {
    final db = await database;
    final batch = db.batch();
    for (final lesson in lessons) {
      batch.insert(
        'lessons',
        lesson.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Lesson>> getLessonsForChapter(int chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'chapterId = ?',
      whereArgs: [chapterId],
      orderBy: 'orderIndex',
    );
    return maps.map((map) => Lesson.fromJson(map)).toList();
  }

  Future<Lesson?> getLesson(int lessonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
    );
    if (maps.isEmpty) return null;
    return Lesson.fromJson(maps.first);
  }

  // Questions CRUD
  Future<void> saveQuestions(List<Question> questions) async {
    if (questions.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final question in questions) {
      batch.insert(
        'questions',
        question.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Question>> getQuestionsForLesson(int lessonId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'lessonId = ?',
      whereArgs: [lessonId],
    );
    return maps.map((map) => Question.fromJson(map)).toList();
  }

  // Progress CRUD
  Future<void> saveProgressList(List<Progress> progressList) async {
    final db = await database;
    final batch = db.batch();
    for (final progress in progressList) {
      batch.insert(
        'progress',
        {
          'id': progress.id,
          'userId': progress.userId,
          'lessonId': progress.lessonId,
          'isCompleted': progress.isCompleted ? 1 : 0,
          'quizScore': progress.quizScore,
          'completionPercent': progress.completionPercent,
          'updatedAt': progress.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Progress>> getProgressList(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) {
      return Progress(
        id: map['id'] as int,
        userId: map['userId'] as int,
        lessonId: map['lessonId'] as int,
        isCompleted: (map['isCompleted'] as int) == 1,
        quizScore: map['quizScore'] != null ? (map['quizScore'] as num).toDouble() : null,
        completionPercent: (map['completionPercent'] as num).toDouble(),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
    }).toList();
  }

  Future<void> saveSingleProgress(Progress progress) async {
    final db = await database;
    await db.insert(
      'progress',
      {
        'id': progress.id,
        'userId': progress.userId,
        'lessonId': progress.lessonId,
        'isCompleted': progress.isCompleted ? 1 : 0,
        'quizScore': progress.quizScore,
        'completionPercent': progress.completionPercent,
        'updatedAt': progress.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Pending Sync Queue
  Future<void> addPendingSync({
    required int userId,
    required int lessonId,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert(
      'pending_sync',
      {
        'userId': userId,
        'lessonId': lessonId,
        'type': type,
        'payload': jsonEncode(payload),
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs(int userId) async {
    final db = await database;
    return await db.query(
      'pending_sync',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
  }

  Future<void> removePendingSync(int syncId) async {
    final db = await database;
    await db.delete(
      'pending_sync',
      where: 'id = ?',
      whereArgs: [syncId],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('chapters');
    await db.delete('lessons');
    await db.delete('questions');
    await db.delete('progress');
    await db.delete('pending_sync');
  }
}
