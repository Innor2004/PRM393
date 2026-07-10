import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../models/badge.dart';
import '../services/backend_service.dart';
import '../services/local_storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();
  final LocalStorageService _storage = LocalStorageService();

  int _userId = 1;
  List<Progress> _progressList = [];

  void setUserId(int id) => _userId = id;
  final List<Badge> _badges = [
    Badge(id: 1, name: 'Nhà vật lý', description: 'Đạt điểm 10 Vật lý đại cương', iconUrl: '🏆', requiredScore: 100),
    Badge(id: 2, name: 'Học sinh chăm chỉ', description: 'Hoàn thành 5 bài học', iconUrl: '⭐', requiredScore: 50),
    Badge(id: 3, name: 'Nhà thám hiểm', description: 'Hoàn thành tất cả chương', iconUrl: '🌟', requiredScore: 200),
  ];
  final List<int> _earnedBadgeIds = [];
  double _overallPercent = 0;

  List<Progress> get progressList => _progressList;
  List<Badge> get badges => _badges;
  List<int> get earnedBadgeIds => _earnedBadgeIds;
  List<Badge> get earnedBadges => _badges.where((b) => _earnedBadgeIds.contains(b.id)).toList();
  double get overallPercent => _overallPercent;

  Future<void> loadProgress() async {
    if (_backend.isAvailable) {
      await _loadFromBackend();
    } else {
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      final res = await _backend.getOne('/progress/me');
      final data = res['data'] as List<dynamic>? ?? [];
      _progressList = data.map((e) => Progress.fromJson(Map<String, dynamic>.from(e))).toList();
      final summary = res['summary'] as Map<String, dynamic>? ?? {};
      _overallPercent = (summary['overall_percent'] as num?)?.toDouble() ?? 0;
      _calculateBadges();
      notifyListeners();
    } catch (_) {
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final data = await _storage.loadData('progress');
    if (data != null) {
      _progressList = (data as List).map((e) => Progress.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    final badgeData = await _storage.loadData('earned_badges');
    if (badgeData != null) {
      _earnedBadgeIds.addAll((badgeData as List).cast<int>());
    }
    _calculateOverall();
    notifyListeners();
  }

  Future<void> markLessonCompleted(int lessonId, {double score = 0}) async {
    if (_backend.isAvailable) {
      await _markOnBackend(lessonId, score);
    } else {
      _markLocally(lessonId, score);
    }
  }

  Future<void> _markOnBackend(int lessonId, double score) async {
    try {
      final res = await _backend.post('/quiz/submit', body: {
        'lesson_id': lessonId,
        'answers': [],
      });
      score = (res['score'] as num?)?.toDouble() ?? score;
    } catch (_) {}

    _progressList.removeWhere((p) => p.lessonId == lessonId);
    _progressList.add(Progress(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: _userId,
      lessonId: lessonId,
      isCompleted: true,
      quizScore: score,
      completionPercent: score >= 5 ? 100 : score * 10,
    ));
    _calculateBadges();
    _calculateOverall();
    notifyListeners();
  }

  void _markLocally(int lessonId, double score) {
    _progressList.removeWhere((p) => p.lessonId == lessonId);
    _progressList.add(Progress(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: _userId,
      lessonId: lessonId,
      isCompleted: true,
      quizScore: score,
      completionPercent: score >= 5 ? 100 : score * 10,
    ));
    _calculateBadges();
    _calculateOverall();
    _persistLocal();
    notifyListeners();
  }

  void _calculateOverall() {
    if (_progressList.isEmpty) {
      _overallPercent = 0;
      return;
    }
    final total = _progressList.fold<double>(0, (sum, p) => sum + p.completionPercent);
    _overallPercent = (total / _progressList.length).clamp(0, 100);
  }

  void _calculateBadges() {
    final totalScore = _progressList.fold<double>(0, (sum, p) => sum + p.quizScore);
    for (final badge in _badges) {
      if (!_earnedBadgeIds.contains(badge.id) && totalScore >= badge.requiredScore) {
        _earnedBadgeIds.add(badge.id);
      }
    }
    if (_progressList.length >= 5 && !_earnedBadgeIds.contains(2)) {
      _earnedBadgeIds.add(2);
    }
  }

  Future<void> _persistLocal() async {
    await _storage.saveData('progress', _progressList.map((p) => p.toJson()).toList());
    await _storage.saveData('earned_badges', _earnedBadgeIds);
  }

  bool isLessonCompleted(int lessonId) =>
      _progressList.any((p) => p.lessonId == lessonId && p.isCompleted);

  double getLessonScore(int lessonId) {
    final found = _progressList.where((p) => p.lessonId == lessonId).toList();
    if (found.isEmpty) return 0;
    return found.first.quizScore;
  }
}
