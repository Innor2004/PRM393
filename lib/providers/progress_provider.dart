import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../models/badge.dart';
import '../services/backend_service.dart';

class ProgressProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();

  int _userId = 1;
  List<Progress> _progressList = [];
  List<Badge> _userBadges = [];
  double _overallPercent = 0;
  int _totalLessons = 0;

  void setUserId(int id) => _userId = id;

  List<Progress> get progressList => _progressList;
  List<Badge> get userBadges => _userBadges;
  double get overallPercent => _overallPercent;
  int get totalLessons => _totalLessons;

  Future<void> loadProgress() async {
    try {
      final res = await _backend.getOne('/progress/me');
      final data = res['data'] as List<dynamic>? ?? [];
      _progressList = data.map((e) => Progress.fromJson(Map<String, dynamic>.from(e))).toList();
      final summary = res['summary'] as Map<String, dynamic>? ?? {};
      _overallPercent = (summary['overallPercent'] as num?)?.toDouble() ?? 0;
      _totalLessons = (summary['totalLessons'] as num?)?.toInt() ?? 0;
      final badgesJson = res['badges'] as List<dynamic>? ?? [];
      _userBadges = badgesJson.map((e) => Badge.fromJson(Map<String, dynamic>.from(e))).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('loadProgress error: $e');
    }
  }

  Future<void> markLessonCompleted(int lessonId, {double? score}) async {
    if (score == null) {
      try {
        await _backend.post('/progress/complete-lesson/$lessonId');
        await loadProgress();
        return;
      } catch (e) {
        debugPrint('sync complete-lesson error: $e');
      }
    }

    final existing = _progressList.where((p) => p.lessonId == lessonId).toList();
    double? bestScore = score;
    if (existing.isNotEmpty && existing.first.quizScore != null) {
      if (score != null && score < existing.first.quizScore!) {
        bestScore = existing.first.quizScore;
      } else if (score == null) {
        bestScore = existing.first.quizScore;
      }
    }

    _progressList.removeWhere((p) => p.lessonId == lessonId);
    _progressList.add(Progress(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: _userId,
      lessonId: lessonId,
      isCompleted: true,
      quizScore: bestScore,
      completionPercent: bestScore != null
          ? (bestScore >= 5 ? 100 : bestScore * 10)
          : 100,
    ));
    _calculateOverall();
    notifyListeners();
  }

  void _calculateOverall() {
    if (_totalLessons == 0) {
      _overallPercent = 0;
      return;
    }
    final completed = _progressList
        .where((p) => p.isCompleted)
        .map((p) => p.lessonId)
        .toSet()
        .length;
    _overallPercent = (completed / _totalLessons * 100).clamp(0, 100);
  }

  bool isLessonCompleted(int lessonId) =>
      _progressList.any((p) => p.lessonId == lessonId && p.isCompleted);

  double getLessonScore(int lessonId) {
    final found = _progressList.where((p) => p.lessonId == lessonId).toList();
    if (found.isEmpty) return 0;
    return found.first.quizScore ?? 0;
  }

  bool hasLessonQuiz(int lessonId) {
    final found = _progressList.where((p) => p.lessonId == lessonId).toList();
    if (found.isEmpty) return false;
    return found.first.hasQuiz;
  }
}
