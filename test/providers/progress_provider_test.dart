import 'package:flutter_test/flutter_test.dart';
import 'package:project/providers/progress_provider.dart';

void main() {
  group('ProgressProvider - markLessonCompleted', () {
    test('mark 1 lesson thành công', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 8.0);

      expect(provider.progressList.length, 1);
      expect(provider.progressList[0].lessonId, 1);
      expect(provider.progressList[0].isCompleted, true);
      expect(provider.progressList[0].quizScore, 8.0);
    });

    test('mark 2 lessons khác nhau', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 7.0);
      provider.markLessonCompleted(2, score: 9.0);

      expect(provider.progressList.length, 2);
    });

    test('mark lesson trùng lặp ghi đè', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 5.0);
      provider.markLessonCompleted(1, score: 10.0);

      expect(provider.progressList.length, 1);
      expect(provider.progressList[0].quizScore, 10.0);
    });
  });

  group('ProgressProvider - isLessonCompleted', () {
    test('lesson chưa học trả về false', () {
      final provider = ProgressProvider();

      expect(provider.isLessonCompleted(1), false);
    });

    test('lesson đã học trả về true', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 7.0);

      expect(provider.isLessonCompleted(1), true);
      expect(provider.isLessonCompleted(2), false);
    });
  });

  group('ProgressProvider - getLessonScore', () {
    test('lesson chưa học trả về 0', () {
      final provider = ProgressProvider();

      expect(provider.getLessonScore(1), 0);
    });

    test('lesson đã học trả về điểm đúng', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 8.5);

      expect(provider.getLessonScore(1), 8.5);
    });

    test('lesson đã học sau đó ghi đè điểm', () {
      final provider = ProgressProvider();

      provider.markLessonCompleted(1, score: 3.0);
      provider.markLessonCompleted(1, score: 9.5);

      expect(provider.getLessonScore(1), 9.5);
    });
  });

  group('ProgressProvider - userBadges', () {
    test('khởi tạo không có badge', () {
      final provider = ProgressProvider();

      expect(provider.userBadges, isEmpty);
    });
  });
}
