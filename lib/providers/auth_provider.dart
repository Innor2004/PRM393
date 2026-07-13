import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService =
  AuthService();

  final BackendService _backend =
  BackendService();

  AuthStatus _status =
      AuthStatus.uninitialized;

  User? _user;
  String? _error;

  bool _isLoading = false;
  bool _useBackend = false;

  AuthStatus get status => _status;

  User? get user => _user;

  String? get error => _error;

  bool get isLoading => _isLoading;

  bool get useBackend => _useBackend;

  Future<void> tryAutoLogin() async {
    await _backend.init();

    _useBackend =
    await _backend.checkHealth();

    debugPrint(
      'Use backend: $_useBackend',
    );

    if (_useBackend) {
      final prefs =
      await SharedPreferences.getInstance();

      final savedToken =
      prefs.getString('backend_token');

      if (savedToken != null &&
          savedToken.isNotEmpty) {
        _backend.setToken(savedToken);

        try {
          final result =
          await _backend.getOne(
            '/auth/me',
          );

          _user = User.fromJson(
            Map<String, dynamic>.from(
              result,
            ),
          );

          _status =
              AuthStatus.authenticated;

          notifyListeners();

          return;
        } catch (error) {
          debugPrint(
            'Auto login error: $error',
          );

          _backend.setToken(null);

          await prefs.remove(
            'backend_token',
          );
        }
      }

      _user = null;
      _status =
          AuthStatus.unauthenticated;

      notifyListeners();

      return;
    }

    // Chỉ dùng tài khoản mock nếu backend không chạy.
    await _authService.init();

    if (_authService.isLoggedIn) {
      _user =
          _authService.currentUser;

      _status =
          AuthStatus.authenticated;
    } else {
      _status =
          AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(
      String email,
      String password,
      ) async {
    _setLoading(true);

    // Kiểm tra backend lại khi đăng nhập.
    if (!_useBackend) {
      await _backend.init();

      _useBackend =
      await _backend.checkHealth();
    }

    if (_useBackend) {
      try {
        final result =
        await _backend.post(
          '/auth/login',
          body: {
            'email': email.trim(),
            'password': password,
          },
        );

        final token =
        result['token']?.toString();

        if (token == null ||
            token.isEmpty) {
          throw Exception(
            'Backend không trả về token',
          );
        }

        final userData =
        result['user'];

        if (userData
        is! Map<String, dynamic>) {
          throw Exception(
            'Backend không trả về '
                'thông tin người dùng',
          );
        }

        _backend.setToken(token);

        final prefs =
        await SharedPreferences.getInstance();

        await prefs.setString(
          'backend_token',
          token,
        );

        _user = User.fromJson(
          userData,
        );

        _status =
            AuthStatus.authenticated;

        _setLoading(false);

        return true;
      } catch (error) {
        return _fail(error);
      }
    }

    final user =
    await _authService.login(
      email,
      password,
    );

    if (user != null) {
      _user = user;

      _status =
          AuthStatus.authenticated;

      _setLoading(false);

      return true;
    }

    _error =
    'Email hoặc mật khẩu không đúng';

    _setLoading(false);

    return false;
  }

  Future<bool> signup(
      String name,
      String email,
      String password,
      ) async {
    _setLoading(true);

    if (!_useBackend) {
      await _backend.init();

      _useBackend =
      await _backend.checkHealth();
    }

    if (_useBackend) {
      try {
        final result =
        await _backend.post(
          '/auth/register',
          body: {
            'name': name.trim(),
            'email': email.trim(),
            'password': password,
          },
        );

        final token =
        result['token']?.toString();

        if (token == null ||
            token.isEmpty) {
          throw Exception(
            'Backend không trả về token',
          );
        }

        final userData =
        result['user'];

        if (userData
        is! Map<String, dynamic>) {
          throw Exception(
            'Backend không trả về '
                'thông tin người dùng',
          );
        }

        _backend.setToken(token);

        final prefs =
        await SharedPreferences.getInstance();

        await prefs.setString(
          'backend_token',
          token,
        );

        _user = User.fromJson(
          userData,
        );

        _status =
            AuthStatus.authenticated;

        _setLoading(false);

        return true;
      } catch (error) {
        return _fail(error);
      }
    }

    final user =
    await _authService.signup(
      name,
      email,
      password,
    );

    if (user != null) {
      _user = user;

      _status =
          AuthStatus.authenticated;

      _setLoading(false);

      return true;
    }

    _error =
    'Đăng ký không thành công';

    _setLoading(false);

    return false;
  }

  Future<bool> updateName(
      String name,
      ) async {
    final cleanName = name.trim();

    if (cleanName.length < 2) {
      _error =
      'Tên phải có ít nhất 2 ký tự';

      notifyListeners();

      return false;
    }

    if (cleanName.length > 100) {
      _error =
      'Tên không được vượt quá '
          '100 ký tự';

      notifyListeners();

      return false;
    }

    _setLoading(true);

    try {
      if (_useBackend) {
        final result =
        await _backend.put(
          '/auth/profile',
          body: {
            'name': cleanName,
          },
        );

        _user = User.fromJson(
          result,
        );
      } else {
        _user =
        await _authService.updateProfile(
          name: cleanName,
          avatarUrl:
          _user?.avatarUrl,
        );
      }

      _setLoading(false);

      return _user != null;
    } catch (error) {
      return _fail(error);
    }
  }

  /// Upload avatar hỗ trợ cả Chrome Web và Android.
  Future<bool> uploadAvatar({
    required String filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    if (!_useBackend) {
      await _backend.init();

      _useBackend =
      await _backend.checkHealth();
    }

    if (!_useBackend) {
      _error =
      'Không kết nối được backend';

      notifyListeners();

      return false;
    }

    _setLoading(true);

    try {
      late Map<String, dynamic> result;

      if (kIsWeb) {
        if (bytes == null ||
            bytes.isEmpty) {
          throw Exception(
            'Không đọc được dữ liệu ảnh',
          );
        }

        result =
        await _backend.uploadBytes(
          '/auth/avatar',
          bytes: bytes,
          fileName:
          fileName ?? 'avatar.jpg',
          fieldName: 'avatar',
        );
      } else {
        if (filePath.trim().isEmpty) {
          throw Exception(
            'Không tìm thấy đường dẫn ảnh',
          );
        }

        result =
        await _backend.uploadFile(
          '/auth/avatar',
          filePath: filePath,
          fieldName: 'avatar',
        );
      }

      _user = User.fromJson(
        result,
      );

      _setLoading(false);

      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.trim().isEmpty) {
      _error =
      'Vui lòng nhập mật khẩu hiện tại';

      notifyListeners();

      return false;
    }

    if (newPassword.length < 6) {
      _error =
      'Mật khẩu mới phải có '
          'ít nhất 6 ký tự';

      notifyListeners();

      return false;
    }

    if (newPassword.length > 100) {
      _error =
      'Mật khẩu mới không được '
          'vượt quá 100 ký tự';

      notifyListeners();

      return false;
    }

    if (currentPassword ==
        newPassword) {
      _error =
      'Mật khẩu mới phải khác '
          'mật khẩu hiện tại';

      notifyListeners();

      return false;
    }

    if (!_useBackend) {
      await _backend.init();

      _useBackend =
      await _backend.checkHealth();
    }

    if (!_useBackend) {
      _error =
      'Không kết nối được backend';

      notifyListeners();

      return false;
    }

    _setLoading(true);

    try {
      await _backend.put(
        '/auth/password',
        body: {
          'currentPassword':
          currentPassword,
          'newPassword':
          newPassword,
        },
      );

      _setLoading(false);

      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<void> logout() async {
    _backend.setToken(null);

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'backend_token',
    );

    await _authService.logout();

    _user = null;

    _status =
        AuthStatus.unauthenticated;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    if (value) {
      _error = null;
    }

    notifyListeners();
  }

  bool _fail(Object error) {
    _error = error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    _setLoading(false);

    return false;
  }
}