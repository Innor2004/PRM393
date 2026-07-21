import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/models/lesson.dart';
import 'package:project/models/user.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/lesson_provider.dart';
import 'package:project/providers/progress_provider.dart';
import 'package:project/providers/quiz_provider.dart';
import 'package:project/providers/theme_provider.dart';
import 'package:project/screens/splash_screen.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/screens/home/home_screen.dart';
import 'package:project/screens/home/chapter_lessons_screen.dart';
import 'package:project/screens/lesson/lesson_detail_screen.dart';
import 'package:project/screens/quiz/quiz_screen.dart';
import 'package:project/screens/admin/admin_dashboard.dart';
import 'package:project/theme.dart';

typedef OnRouteChanged = void Function(String routeName);

class TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];
  final List<String> poppedRoutes = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name != null) {
      pushedRoutes.add(route.settings.name!);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route.settings.name != null) {
      poppedRoutes.add(route.settings.name!);
    }
  }
}

class FakeQuizForNav extends QuizProvider {
  @override
  Future<bool> hasQuestions(int lessonId) async => true;
}

class FakeAuthForNav extends AuthProvider {
  User? _fakeUser;

  @override
  User? get user => _fakeUser;

  void setUser(User u) => _fakeUser = u;

  @override
  Future<void> logout() async {}
}

Widget buildSplashApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ChangeNotifierProvider<LessonProvider>(create: (_) => LessonProvider()),
      ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
      ChangeNotifierProvider<QuizProvider>(create: (_) => QuizProvider()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const HomeScreen(),
            );
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SplashScreen(),
            );
        }
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.setMode(ThemeMode.light);
  });

  group('Navigation - Splash', () {
    testWidgets('Splash → Login khi chưa đăng nhập', (tester) async {
      await tester.pumpWidget(buildSplashApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('PhysicsBook'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
    });
  });

  group('Navigation - LessonDetail → Quiz', () {
    testWidgets('tap nút "Làm bài tập" → đến màn hình Quiz', (tester) async {
      final observer = TestNavigatorObserver();
      final lesson = Lesson(id: 1, chapterId: 1, title: 'Bài 1', orderIndex: 1, estimatedMinutes: 15);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<QuizProvider>(create: (_) => FakeQuizForNav()),
            ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
          ],
          child: MaterialApp(
            home: LessonDetailScreen(lesson: lesson),
            navigatorObservers: [observer],
            routes: {
              '/quiz': (context) => const Scaffold(
                    body: Center(child: Text('Màn hình Quiz')),
                  ),
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Làm bài tập trắc nghiệm'), 100);
      await tester.tap(find.text('Làm bài tập trắc nghiệm'));
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes, contains('/quiz'));
      expect(find.text('Màn hình Quiz'), findsOneWidget);
    });
  });

  group('Navigation - LessonDetail → Quiz (AppBar icon)', () {
    testWidgets('tap icon quiz trên AppBar → đến màn hình Quiz', (tester) async {
      final observer = TestNavigatorObserver();
      final lesson = Lesson(id: 1, chapterId: 1, title: 'Bài 1', orderIndex: 1, estimatedMinutes: 15);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<QuizProvider>(create: (_) => FakeQuizForNav()),
            ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
          ],
          child: MaterialApp(
            home: LessonDetailScreen(lesson: lesson),
            navigatorObservers: [observer],
            routes: {
              '/quiz': (context) => const Scaffold(
                    body: Center(child: Text('Quiz Screen')),
                  ),
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Làm bài tập'));
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes, contains('/quiz'));
    });
  });

  group('Navigation - Login → Register', () {
    testWidgets('tap "Đăng ký" → đến màn hình Register', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(create: (_) => FakeAuthForNav()),
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      await tester.ensureVisible(find.text('Đăng ký'));
      await tester.pump();
      await tester.tap(find.text('Đăng ký'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });

  group('Navigation - Home → Profile tab', () {
    testWidgets('tap "Hồ sơ" bottom nav → hiển thị Profile', (tester) async {
      final auth = FakeAuthForNav();
      auth.setUser(User(id: 1, name: 'Test', email: 'test@test.com', role: 'Student'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<LessonProvider>(
                create: (_) => LessonProvider()),
            ChangeNotifierProvider<ProgressProvider>(
                create: (_) => ProgressProvider()),
            ChangeNotifierProvider<ThemeProvider>(
                create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Hồ sơ'));
      await tester.pump();

      expect(find.text('Huy hiệu'), findsOneWidget);
    });
  });
}
