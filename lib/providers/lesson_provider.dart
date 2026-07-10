import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import '../services/backend_service.dart';

class LessonProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final BackendService _backend = BackendService();

  List<Chapter> _chapters = [];
  List<Lesson> _currentLessons = [];
  Lesson? _currentLesson;
  bool _isLoading = false;
  bool _useBackend = false;

  List<Chapter> get chapters => _chapters;
  List<Lesson> get currentLessons => _currentLessons;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;

  void loadChapters() {
    _isLoading = true;
    notifyListeners();
    _useBackend = _backend.isAvailable;

    if (_useBackend) {
      _loadChaptersFromBackend();
    } else {
      _chapters = _api.getChapters();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadChaptersFromBackend() async {
    try {
      final data = await _backend.getList('/chapters');
      _chapters = data.map((j) => Chapter.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (_) {
      _chapters = _api.getChapters();
    }
    _isLoading = false;
    notifyListeners();
  }

  void loadLessons(int chapterId) {
    _isLoading = true;
    notifyListeners();
    _useBackend = _backend.isAvailable;

    if (_useBackend) {
      _loadLessonsFromBackend(chapterId);
    } else {
      _currentLessons = _api.getLessons(chapterId);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLessonsFromBackend(int chapterId) async {
    try {
      final data = await _backend.getList('/chapters/$chapterId/lessons');
      _currentLessons = data.map((j) => Lesson.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (_) {
      _currentLessons = _api.getLessons(chapterId);
    }
    _isLoading = false;
    notifyListeners();
  }

  void loadLesson(int lessonId) {
    _useBackend = _backend.isAvailable;
    if (_useBackend) {
      _loadLessonFromBackend(lessonId);
    } else {
      _currentLesson = _api.getLesson(lessonId);
      notifyListeners();
    }
  }

  Future<void> _loadLessonFromBackend(int lessonId) async {
    try {
      final data = await _backend.getOne('/lessons/$lessonId');
      _currentLesson = Lesson.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      _currentLesson = _api.getLesson(lessonId);
    }
    notifyListeners();
  }
}
