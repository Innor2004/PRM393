import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/question.dart';
import '../services/backend_service.dart';
import '../services/offline_database_service.dart';

class LessonProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();
  final OfflineDatabaseService _offlineDb = OfflineDatabaseService();

  List<Chapter> _chapters = [];
  List<Lesson> _currentLessons = [];
  Lesson? _currentLesson;
  bool _isLoading = false;
  final Map<int, List<Lesson>> _chapterLessons = {};
  final Map<int, Lesson> _lessonMap = {};

  List<Chapter> get chapters => _chapters;
  List<Lesson> get currentLessons => _currentLessons;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  Map<int, Lesson> get lessonMap => _lessonMap;

  Future<void> loadChapters() async {
    _isLoading = true;
    notifyListeners();

    final isSupportedDb = !kIsWeb;

    try {
      final data = await _backend.getList('/chapters');
      _chapters = data.map((j) => Chapter.fromJson(Map<String, dynamic>.from(j))).toList();
      // Cache chapters locally if supported
      if (isSupportedDb) {
        await _offlineDb.saveChapters(_chapters);
      }
    } catch (e) {
      debugPrint('loadChapters online error: $e');
      if (isSupportedDb) {
        debugPrint('loading from local DB');
        try {
          _chapters = await _offlineDb.getChapters();
        } catch (dbError) {
          debugPrint('loadChapters offline DB error: $dbError');
          _chapters = [];
        }
      } else {
        _chapters = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLessons(int chapterId) async {
    _isLoading = true;
    notifyListeners();

    final isSupportedDb = !kIsWeb;

    try {
      final data = await _backend.getList('/chapters/$chapterId/lessons');
      _currentLessons = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
      // Cache lessons locally if supported
      if (isSupportedDb) {
        await _offlineDb.saveLessons(_currentLessons);
      }
    } catch (e) {
      debugPrint('loadLessons online error: $e');
      if (isSupportedDb) {
        debugPrint('loading from local DB');
        try {
          _currentLessons = await _offlineDb.getLessonsForChapter(chapterId);
        } catch (dbError) {
          debugPrint('loadLessons offline DB error: $dbError');
          _currentLessons = [];
        }
      } else {
        _currentLessons = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLesson(int lessonId) async {
    final isSupportedDb = !kIsWeb;

    try {
      final data = await _backend.getOne('/lessons/$lessonId');
      _currentLesson = Lesson.fromJson(Map<String, dynamic>.from(data));
      // Cache single lesson locally if supported
      if (isSupportedDb) {
        await _offlineDb.saveLessons([_currentLesson!]);
      }
    } catch (e) {
      debugPrint('loadLesson online error: $e');
      if (isSupportedDb) {
        debugPrint('loading from local DB');
        try {
          _currentLesson = await _offlineDb.getLesson(lessonId);
        } catch (dbError) {
          debugPrint('loadLesson offline DB error: $dbError');
          _currentLesson = null;
        }
      } else {
        _currentLesson = null;
      }
    }
    notifyListeners();
  }

  Future<void> loadAllLessons(List<Chapter> chapters) async {
    _chapterLessons.clear();
    _lessonMap.clear();
    final isSupportedDb = !kIsWeb;

    await Future.wait(chapters.map((c) async {
      try {
        final data = await _backend.getList('/chapters/${c.id}/lessons');
        final lessons = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
        _chapterLessons[c.id] = lessons;
        for (final l in lessons) {
          _lessonMap[l.id] = l;
        }
        // Cache all lessons locally if supported
        if (isSupportedDb) {
          await _offlineDb.saveLessons(lessons);

          // Pre-fetch and cache questions for all loaded lessons in the background
          for (final l in lessons) {
            try {
              final qData = await _backend.getList('/lessons/${l.id}/questions');
              final questions = qData.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
              await _offlineDb.saveQuestions(questions);
            } catch (qError) {
              debugPrint('Pre-fetch questions error for lesson ${l.id}: $qError');
            }
          }
        }
      } catch (e) {
        debugPrint('loadLessons online error for chapter ${c.id}: $e');
        if (isSupportedDb) {
          debugPrint('loading from local DB for chapter ${c.id}');
          try {
            final localLessons = await _offlineDb.getLessonsForChapter(c.id);
            _chapterLessons[c.id] = localLessons;
            for (final l in localLessons) {
              _lessonMap[l.id] = l;
            }
          } catch (dbError) {
            debugPrint('loadLessons offline DB error for chapter ${c.id}: $dbError');
            _chapterLessons[c.id] = [];
          }
        } else {
          _chapterLessons[c.id] = [];
        }
      }
    }));
    notifyListeners();
  }

  bool isChapterFullyCompleted(int chapterId, List<int> completedLessonIds) {
    final lessons = _chapterLessons[chapterId];
    if (lessons == null || lessons.isEmpty) return false;
    return lessons.every((l) => completedLessonIds.contains(l.id));
  }
}
