import 'package:flutter_test/flutter_test.dart';
import 'package:project/providers/progress_provider.dart';

void main() {
  group('Quiz Flow - ProgressProvider integration', () {
    late ProgressProvider progress;

    setUp(() {
      progress = ProgressProvider();
    });

    test('hoàn thành 1 bài học → overallPercent = 0 (chưa set totalLessons)', () {
      progress.markLessonCompleted(1, score: 8.0);

      expect(progress.progressList.length, 1);
      expect(progress.overallPercent, 0);
    });

    test('hoàn thành nhiều bài học → danh sách progress đúng', () {
      progress.markLessonCompleted(1, score: 7.0);
      progress.markLessonCompleted(2, score: 8.0);
      progress.markLessonCompleted(3, score: 9.0);

      expect(progress.progressList.length, 3);
      expect(progress.isLessonCompleted(1), true);
      expect(progress.isLessonCompleted(2), true);
      expect(progress.isLessonCompleted(3), true);
      expect(progress.isLessonCompleted(4), false);
    });

    test('hoàn thành bài → ghi đè điểm → lấy điểm mới nhất', () {
      progress.markLessonCompleted(1, score: 4.0);
      expect(progress.getLessonScore(1), 4.0);

      progress.markLessonCompleted(1, score: 9.5);
      expect(progress.getLessonScore(1), 9.5);
      expect(progress.progressList.length, 1);
    });

    test('userBadges luôn empty (badge chỉ đến từ backend)', () {
      progress.markLessonCompleted(1, score: 10.0);

      expect(progress.userBadges, isEmpty);
    });

    test('completionPercent: score >= 5 → 100, score < 5 → score*10', () {
      progress.markLessonCompleted(1, score: 7.0);
      expect(progress.progressList[0].completionPercent, 100);

      progress.markLessonCompleted(2, score: 3.0);
      expect(progress.progressList[1].completionPercent, 30);
    });
  });
}
