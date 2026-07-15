import 'package:flutter_test/flutter_test.dart';
import 'package:project/providers/quiz_provider.dart';

void main() {
  group('QuizProvider - khởi tạo', () {
    test('initial state đúng', () {
      final provider = QuizProvider();

      expect(provider.isLoading, false);
      expect(provider.questions, isEmpty);
      expect(provider.currentIndex, 0);
      expect(provider.totalQuestions, 0);
      expect(provider.selectedAnswer, isNull);
      expect(provider.isSubmitted, false);
      expect(provider.correctCount, 0);
      expect(provider.score, 0);
    });
  });

  group('QuizProvider - selectAnswer', () {
    test('chọn đáp án C', () {
      final provider = QuizProvider();

      provider.selectAnswer('C');

      expect(provider.selectedAnswer, 'C');
    });

    test('chọn đáp án sau khi submit không thay đổi', () {
      final provider = QuizProvider();

      provider.selectAnswer('A');
      provider.selectAnswer('B');

      expect(provider.selectedAnswer, 'B');
    });
  });

  group('QuizProvider - reset', () {
    test('reset xóa toàn bộ state', () {
      final provider = QuizProvider();

      provider.selectAnswer('A');
      provider.reset();

      expect(provider.selectedAnswer, isNull);
      expect(provider.isSubmitted, false);
      expect(provider.currentIndex, 0);
      expect(provider.correctCount, 0);
      expect(provider.score, 0);
    });
  });

  group('QuizProvider - submitToBackend fallback', () {
    test('khi backend fail vẫn trả về score 0', () async {
      final provider = QuizProvider();

      final score = await provider.submitToBackend(999);

      expect(provider.isSubmitted, true);
      expect(score, 0);
      expect(provider.correctCount, 0);
    });
  });
}
