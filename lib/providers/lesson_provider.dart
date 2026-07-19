import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../services/backend_service.dart';

class LessonProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();

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

    try {
      final data = await _backend.getList('/chapters');
      _chapters = data.map((j) => Chapter.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('loadChapters error: $e');
      _chapters = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLessons(int chapterId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _backend.getList('/chapters/$chapterId/lessons');
      _currentLessons = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('loadLessons error: $e');
      _currentLessons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLesson(int lessonId) async {
    try {
      final data = await _backend.getOne('/lessons/$lessonId');
      _currentLesson = Lesson.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      debugPrint('loadLesson error: $e');
      _currentLesson = null;
    }
    notifyListeners();
  }

  Future<void> loadAllLessons(List<Chapter> chapters) async {
    _chapterLessons.clear();
    _lessonMap.clear();
    await Future.wait(chapters.map((c) async {
      try {
        final data = await _backend.getList('/chapters/${c.id}/lessons');
        final lessons = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
        _chapterLessons[c.id] = lessons;
        for (final l in lessons) {
          _lessonMap[l.id] = l;
        }
      } catch (e) {
        debugPrint('loadLessons for chapter ${c.id} error: $e');
        _chapterLessons[c.id] = [];
      }
    }));
    notifyListeners();
  }

  bool isChapterFullyCompleted(int chapterId, List<int> completedLessonIds) {
    final lessons = _chapterLessons[chapterId];
    if (lessons == null || lessons.isEmpty) return false;
    return lessons.every((l) => completedLessonIds.contains(l.id));
  }

  String getChapterProgressStr(int chapterId, List<int> completedLessonIds) {
    final lessons = _chapterLessons[chapterId];
    if (lessons == null || lessons.isEmpty) return '0/0';
    final completed = lessons.where((l) => completedLessonIds.contains(l.id)).length;
    return '$completed/${lessons.length}';
  }
}
