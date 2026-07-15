import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/models/badge.dart';
import 'package:project/models/user.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/progress_provider.dart';
import 'package:project/providers/theme_provider.dart';
import 'package:project/screens/profile/profile_screen.dart';
import 'package:project/theme.dart';

class FakeAuthProvider extends AuthProvider {
  User? _fakeUser;
  String _fakeBackendUrl = 'http://test.com';

  @override
  User? get user => _fakeUser;
  @override
  String get backendUrl => _fakeBackendUrl;
  @override
  bool get isLoading => false;
  @override
  String? get error => null;

  void setUser(User u) => _fakeUser = u;

  @override
  Future<void> updateBackendUrl(String url) async => _fakeBackendUrl = url;
  @override
  Future<bool> updateName(String name) async => true;
  @override
  Future<bool> changePassword({String? currentPassword, String? newPassword}) async => true;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> uploadAvatar({String? filePath, List<int>? bytes, String? fileName}) async => true;
  @override
  void clearError() {}
}

Widget buildTestApp({
  required AuthProvider auth,
  required ProgressProvider progress,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<ProgressProvider>.value(value: progress),
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
      ),
    ],
    child: const MaterialApp(
      home: ProfileScreen(),
    ),
  );
}

void main() {
  late FakeAuthProvider auth;
  late ProgressProvider progress;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.setMode(ThemeMode.light);
    auth = FakeAuthProvider();
    auth.setUser(User(id: 1, name: 'Nguyễn Văn A', email: 'a@test.com'));
    progress = ProgressProvider();
  });

  group('ProfileScreen - hiển thị badge', () {
    testWidgets('hiển thị danh sách badge khi có dữ liệu', (tester) async {
      progress.markLessonCompleted(1, score: 9.0);
      progress.markLessonCompleted(2, score: 9.0);
      progress.markLessonCompleted(3, score: 9.0);

      await tester.pumpWidget(buildTestApp(auth: auth, progress: progress));
      await tester.pumpAndSettle();

      expect(find.text('Huy hiệu'), findsOneWidget);
    });

    testWidgets('hiển thị empty state khi chưa có badge', (tester) async {
      await tester.pumpWidget(buildTestApp(auth: auth, progress: progress));
      await tester.pumpAndSettle();

      expect(find.textContaining('Chưa có huy hiệu'), findsOneWidget);
    });
  });
}
