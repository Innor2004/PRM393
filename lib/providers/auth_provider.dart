import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BackendService _backend = BackendService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;
  bool _isLoading = false;
  bool _useBackend = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    await _backend.init();
    await _backend.checkHealth();
    _useBackend = _backend.isAvailable;

    if (_useBackend) {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('backend_token');
      if (savedToken != null) {
        _backend.setToken(savedToken);
        try {
          final me = await _backend.getOne('/auth/me');
          _user = User.fromJson(Map<String, dynamic>.from(me));
          _status = AuthStatus.authenticated;
          notifyListeners();
          return;
        } catch (_) {
          await prefs.remove('backend_token');
        }
      }
    }

    await _authService.init();
    if (_authService.isLoggedIn) {
      _user = _authService.currentUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_useBackend) {
      try {
        final res = await _backend.post('/auth/login', body: {
          'email': email,
          'password': password,
        });
        final token = res['token'] as String;
        _backend.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backend_token', token);

        _user = User.fromJson(Map<String, dynamic>.from(res['user']));
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final user = await _authService.login(email, password);
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email hoặc mật khẩu không đúng';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_useBackend) {
      try {
        final res = await _backend.post('/auth/register', body: {
          'name': name,
          'email': email,
          'password': password,
        });
        final token = res['token'] as String;
        _backend.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backend_token', token);

        _user = User.fromJson(Map<String, dynamic>.from(res['user']));
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final user = await _authService.signup(name, email, password);
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Đăng ký không thành công';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _backend.setToken(null);
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
