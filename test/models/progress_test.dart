import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/progress.dart';

void main() {
  group('Progress.fromJson', () {
    test('parse JSON camelCase', () {
      final json = {
        'id': 1,
        'userId': 1,
        'lessonId': 1,
        'isCompleted': true,
        'quizScore': 8.5,
        'completionPercent': 100.0,
        'updatedAt': '2026-07-15T10:30:00Z',
      };

      final progress = Progress.fromJson(json);

      expect(progress.id, 1);
      expect(progress.userId, 1);
      expect(progress.lessonId, 1);
      expect(progress.isCompleted, true);
      expect(progress.quizScore, 8.5);
      expect(progress.completionPercent, 100.0);
    });

    test('parse JSON snake_case', () {
      final json = {
        'id': 2,
        'user_id': 1,
        'lesson_id': 3,
        'is_completed': false,
        'quiz_score': 0,
        'completion_percent': 0,
        'updated_at': '2026-07-15T11:00:00Z',
      };

      final progress = Progress.fromJson(json);

      expect(progress.id, 2);
      expect(progress.userId, 1);
      expect(progress.lessonId, 3);
      expect(progress.isCompleted, false);
      expect(progress.quizScore, 0);
      expect(progress.completionPercent, 0);
    });
  });

  group('Progress.copyWith', () {
    test('copyWith thay đổi field', () {
      final original = Progress(
        id: 1,
        userId: 1,
        lessonId: 1,
        isCompleted: false,
        quizScore: 0,
        completionPercent: 0,
      );

      final copy = original.copyWith(isCompleted: true, quizScore: 9.0);

      expect(copy.id, 1);
      expect(copy.isCompleted, true);
      expect(copy.quizScore, 9.0);
      expect(copy.completionPercent, 0);
    });
  });
}
