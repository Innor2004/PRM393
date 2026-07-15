import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/lesson.dart';
import 'package:project/screens/lesson/lesson_detail_screen.dart';
import 'package:project/theme.dart';

void main() {
  testWidgets('LessonDetailScreen hiển thị nội dung bài học', (tester) async {
    AppColors.setMode(ThemeMode.light);
    final lesson = Lesson(id: 1, chapterId: 1, title: 'Chuyển động thẳng đều',
        orderIndex: 1, estimatedMinutes: 20,
        contentBody: '# Bài 1\nNội dung bài học');

    await tester.pumpWidget(
      MaterialApp(home: LessonDetailScreen(lesson: lesson)),
    );
    await tester.pump();

    expect(find.text('Chuyển động thẳng đều'), findsOneWidget);
    expect(find.textContaining('Nội dung bài học'), findsOneWidget);
  });
}
