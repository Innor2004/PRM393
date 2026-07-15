import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/lesson.dart';
import 'package:project/providers/progress_provider.dart';
import 'package:project/providers/quiz_provider.dart';
import 'package:project/screens/quiz/quiz_screen.dart';
import 'package:project/theme.dart';

Widget buildQuizTestApp({
  required QuizProvider quiz,
  required Lesson lesson,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<QuizProvider>.value(value: quiz),
      ChangeNotifierProvider<ProgressProvider>(
        create: (_) => ProgressProvider(),
      ),
    ],
    child: MaterialApp(
      home: QuizScreen(lesson: lesson),
    ),
  );
}

void main() {
  group('QuizScreen - hiển thị', () {
    testWidgets('hiển thị màn hình quiz với tiêu đề bài học', (tester) async {
      AppColors.setMode(ThemeMode.light);
      final quiz = QuizProvider();
      final lesson = Lesson(id: 1, chapterId: 1, title: 'Chuyển động thẳng đều', orderIndex: 1);

      await tester.pumpWidget(buildQuizTestApp(quiz: quiz, lesson: lesson));
      await tester.pump();

      expect(find.textContaining('Chuyển động thẳng đều'), findsOneWidget);
    });

    testWidgets('hiển thị trạng thái không có câu hỏi', (tester) async {
      AppColors.setMode(ThemeMode.light);
      final quiz = QuizProvider();
      final lesson = Lesson(id: 99, chapterId: 1, title: 'Bài test', orderIndex: 1);

      await tester.pumpWidget(buildQuizTestApp(quiz: quiz, lesson: lesson));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('Chưa có câu hỏi cho bài học này'), findsOneWidget);
    });

    testWidgets('hiển thị thông tin bài học trên AppBar', (tester) async {
      AppColors.setMode(ThemeMode.light);
      final quiz = QuizProvider();
      final lesson = Lesson(id: 1, chapterId: 1, title: 'Chuyển động thẳng đều', orderIndex: 1);

      await tester.pumpWidget(buildQuizTestApp(quiz: quiz, lesson: lesson));
      await tester.pump();

      expect(find.textContaining('Bài tập:'), findsOneWidget);
    });
  });
}
