import '../models/lesson.dart';
import 'local_storage_service.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._();
  factory OfflineService() => _instance;
  OfflineService._();

  final LocalStorageService _storage = LocalStorageService();

  Future<void> saveLesson(Lesson lesson) async {
    final lessons = await getSavedLessons();
    final exists = lessons.any((l) => l.id == lesson.id);
    if (!exists) {
      lessons.add(lesson);
      await _storage.saveData('offline_lessons', lessons.map((l) => l.toJson()).toList());
    }
  }

  Future<List<Lesson>> getSavedLessons() async {
    final data = await _storage.loadData('offline_lessons');
    if (data == null) return [];
    return (data as List).map((e) => Lesson.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> removeLesson(int lessonId) async {
    final lessons = await getSavedLessons();
    lessons.removeWhere((l) => l.id == lessonId);
    await _storage.saveData('offline_lessons', lessons.map((l) => l.toJson()).toList());
  }

  Future<bool> isSaved(int lessonId) async {
    final lessons = await getSavedLessons();
    return lessons.any((l) => l.id == lessonId);
  }

  Future<Lesson?> getLesson(int lessonId) async {
    final lessons = await getSavedLessons();
    return lessons.cast<Lesson?>().firstWhere((l) => l?.id == lessonId, orElse: () => null);
  }
}
