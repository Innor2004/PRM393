import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _demoEmail = 'demo@test.com';
  static const _demoPassword = '123456';
  static const _adminEmail = 'admin@test.com';
  static const _adminPassword = 'admin123';

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    if (_token != null) {
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        try {
          final map = jsonDecode(userJson) as Map<String, dynamic>;
          _currentUser = User.fromJson(map);
        } catch (_) {
          // ignore corrupted session data
          _token = null;
        }
      }
    }
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == _demoEmail && password == _demoPassword) {
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = User(
        id: 1,
        name: 'Nam',
        email: email,
        role: 'Student',
      );
      await _persistSession();
      return _currentUser;
    }
    if (email == _adminEmail && password == _adminPassword) {
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = User(
        id: 2,
        name: 'Quản trị viên',
        email: email,
        role: 'Admin',
      );
      await _persistSession();
      return _currentUser;
    }
    return null;
  }

  Future<User?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
      role: 'Student',
    );
    await _persistSession();
    return _currentUser;
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    }
  }
}
