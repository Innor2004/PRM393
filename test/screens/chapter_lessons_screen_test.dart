import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/models/chapter.dart';
import 'package:project/providers/lesson_provider.dart';
import 'package:project/providers/progress_provider.dart';
import 'package:project/screens/home/chapter_lessons_screen.dart';
import 'package:project/theme.dart';

Widget buildTestApp({
  required Chapter chapter,
  required LessonProvider lessonProvider,
  required ProgressProvider progressProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LessonProvider>.value(value: lessonProvider),
      ChangeNotifierProvider<ProgressProvider>.value(value: progressProvider),
    ],
    child: MaterialApp(
      home: ChapterLessonsScreen(chapter: chapter),
    ),
  );
}

void main() {
  late Chapter chapter;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.setMode(ThemeMode.light);
    chapter = Chapter(id: 1, bookId: 1, title: 'Động học chất điểm',
        description: 'Chuyển động thẳng đều', orderIndex: 1);
  });

  group('ChapterLessonsScreen', () {
    testWidgets('hiển thị AppBar với tên chương', (tester) async {
      await tester.pumpWidget(buildTestApp(
        chapter: chapter,
        lessonProvider: LessonProvider(),
        progressProvider: ProgressProvider(),
      ));
      await tester.pump();

      expect(find.text('Động học chất điểm'), findsOneWidget);
    });

    testWidgets('hiển thị empty state khi load lesson thất bại', (tester) async {
      await tester.pumpWidget(buildTestApp(
        chapter: chapter,
        lessonProvider: LessonProvider(),
        progressProvider: ProgressProvider(),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Không có bài học nào'), findsOneWidget);
    });
  });
}
