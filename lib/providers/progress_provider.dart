import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/progress.dart';
import '../models/badge.dart';
import '../services/backend_service.dart';
import '../services/offline_database_service.dart';

class ProgressProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();
  final OfflineDatabaseService _offlineDb = OfflineDatabaseService();

  int _userId = 1;
  List<Progress> _progressList = [];
  List<Badge> _userBadges = [];
  double _overallPercent = 0;
  int _totalLessons = 0;
  int _pendingCount = 0;

  void setUserId(int id) {
    _userId = id;
  }

  List<Progress> get progressList => _progressList;
  List<Badge> get userBadges => _userBadges;
  double get overallPercent => _overallPercent;
  int get totalLessons => _totalLessons;
  int get pendingCount => _pendingCount;

  Future<void> updatePendingCount() async {
    final isSupportedDb = !kIsWeb;
    if (!isSupportedDb) return;

    try {
      final pending = await _offlineDb.getPendingSyncs(_userId);
      _pendingCount = pending.length;
      notifyListeners();
    } catch (e) {
      debugPrint('updatePendingCount error: $e');
    }
  }

  Future<void> loadProgress() async {
    final isSupportedDb = !kIsWeb;

    try {
      final res = await _backend.getOne('/progress/me');
      final data = res['data'] as List<dynamic>? ?? [];
      _progressList = data.map((e) => Progress.fromJson(Map<String, dynamic>.from(e))).toList();
      final summary = res['summary'] as Map<String, dynamic>? ?? {};
      _overallPercent = (summary['overallPercent'] as num?)?.toDouble() ?? 0;
      _totalLessons = (summary['totalLessons'] as num?)?.toInt() ?? 0;
      final badgesJson = res['badges'] as List<dynamic>? ?? [];
      _userBadges = badgesJson.map((e) => Badge.fromJson(Map<String, dynamic>.from(e))).toList();

      if (isSupportedDb) {
        // Cache progress locally
        await _offlineDb.saveProgressList(_progressList);
        await updatePendingCount();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('loadProgress online error: $e');
      if (isSupportedDb) {
        debugPrint('loading from local DB');
        try {
          _progressList = await _offlineDb.getProgressList(_userId);

          // Fetch total lessons from offline DB
          final db = await _offlineDb.database;
          _totalLessons = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM lessons')) ?? 0;

          _calculateOverall();
          await updatePendingCount();
        } catch (dbError) {
          debugPrint('loadProgress offline DB error: $dbError');
        }
      }
      notifyListeners();
    }
  }

  Future<void> markLessonCompleted(int lessonId, {double? score}) async {
    final isSupportedDb = !kIsWeb;

    if (score == null) {
      try {
        await _backend.post('/progress/complete-lesson/$lessonId');
        await loadProgress();
        return;
      } catch (e) {
        debugPrint('sync complete-lesson error: $e');
        if (isSupportedDb) {
          debugPrint('saving offline');
          try {
            await _offlineDb.addPendingSync(
              userId: _userId,
              lessonId: lessonId,
              type: 'complete_lesson',
              payload: {'lessonId': lessonId},
            );
          } catch (dbError) {
            debugPrint('Failed to queue offline complete lesson: $dbError');
          }
        }
      }
    }

    final newProgress = Progress(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: _userId,
      lessonId: lessonId,
      isCompleted: true,
      quizScore: score,
      completionPercent: score != null
          ? (score >= 5 ? 100 : score * 10)
          : 100,
      updatedAt: DateTime.now(),
    );

    _progressList.removeWhere((p) => p.lessonId == lessonId);
    _progressList.add(newProgress);

    if (isSupportedDb) {
      try {
        await _offlineDb.saveSingleProgress(newProgress);
      } catch (dbError) {
        debugPrint('Failed to save progress locally: $dbError');
      }
    }

    _calculateOverall();
    if (isSupportedDb) {
      await updatePendingCount();
    } else {
      notifyListeners();
    }
  }

  Future<bool> syncPendingData() async {
    final isSupportedDb = !kIsWeb;
    if (!isSupportedDb) return true;

    try {
      final pending = await _offlineDb.getPendingSyncs(_userId);
      if (pending.isEmpty) return true;

      debugPrint('Found ${pending.length} pending sync items. Starting synchronization...');

      bool allSynced = true;

      for (final item in pending) {
        final syncId = item['id'] as int;
        final lessonId = item['lessonId'] as int;
        final type = item['type'] as String;
        final payload = jsonDecode(item['payload'] as String) as Map<String, dynamic>;

        try {
          if (type == 'complete_lesson') {
            await _backend.post('/progress/complete-lesson/$lessonId');
          } else if (type == 'quiz_submit') {
            await _backend.post('/quiz/submit', body: payload);
          }

          // If request succeeded, remove from pending queue
          await _offlineDb.removePendingSync(syncId);
          debugPrint('Successfully synced item $syncId (type: $type, lesson: $lessonId)');
        } catch (e) {
          debugPrint('Failed to sync item $syncId: $e');
          allSynced = false;
        }
      }

      // Refresh state from backend
      await loadProgress();
      return allSynced;
    } catch (e) {
      debugPrint('syncPendingData error: $e');
      return false;
    }
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
