import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/chapter_lessons_screen.dart';
import 'screens/lesson/lesson_detail_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: 'X-IBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/splash':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/chapter-lessons':
              final chapter = settings.arguments as dynamic;
              return MaterialPageRoute(
                builder: (_) => ChapterLessonsScreen(chapter: chapter),
              );
            case '/lesson-detail':
              final lesson = settings.arguments as dynamic;
              return MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: lesson),
              );
            case '/quiz':
              final lesson = settings.arguments as dynamic;
              return MaterialPageRoute(
                builder: (_) => QuizScreen(lesson: lesson),
              );
            case '/admin':
              return MaterialPageRoute(builder: (_) => const AdminDashboard());
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
