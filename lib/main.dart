import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/auth_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/chapter_lessons_screen.dart';
import 'screens/lesson/lesson_detail_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/quiz/quiz_history_screen.dart';
import 'screens/quiz/quiz_history_detail_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) {
          return MaterialApp(
            key: ValueKey(tp.themeMode),
            title: 'PhysicsBook',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: tp.themeMode,
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
                case '/chapter-lessons':
                  final chapter = settings.arguments as dynamic;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => ChapterLessonsScreen(chapter: chapter),
                  );
                case '/lesson-detail':
                  final lesson = settings.arguments as dynamic;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => LessonDetailScreen(lesson: lesson),
                  );
                case '/quiz':
                  final lesson = settings.arguments as dynamic;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => QuizScreen(lesson: lesson),
                  );
                case '/quiz-history':
                  final lesson = settings.arguments as dynamic;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => QuizHistoryScreen(lesson: lesson),
                  );
                case '/quiz-history-detail':
                  final attempt = settings.arguments as dynamic;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => QuizHistoryDetailScreen(attempt: attempt),
                  );
                case '/admin':
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => const AdminDashboard(),
                  );
                default:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
