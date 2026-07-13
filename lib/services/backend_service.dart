import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class BackendService {
  static final BackendService _instance = BackendService._();
  factory BackendService() => _instance;
  BackendService._();

  static const String _baseUrlKey = 'backend_base_url';
  String _baseUrl = kIsWeb ? 'http://localhost:5271/api' : 'http://10.0.2.2:5271/api';
  bool _isAvailable = false;

  String get baseUrl => _baseUrl;
  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_baseUrlKey) ?? _baseUrl;
    if (kIsWeb && _baseUrl.contains('10.0.2.2')) {
      _baseUrl = 'http://localhost:5271/api';
    }
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  Future<void> checkHealth() async {
    try {
      debugPrint('Checking health at: $_baseUrl/chapters');
      final res = await http.get(
        Uri.parse('$_baseUrl/chapters'),
      ).timeout(const Duration(seconds: 3));
      _isAvailable = res.statusCode == 200 || res.statusCode == 401;
      debugPrint('Health check response code: ${res.statusCode}, isAvailable: $_isAvailable');
    } catch (e) {
      debugPrint('Health check exception: $e');
      _isAvailable = false;
    }
  }

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _request(Future<http.Response> Function() fn) async {
    return fn().timeout(const Duration(seconds: 10));
  }

  Future<List<dynamic>> getList(String path) async {
    final res = await _request(() => http.get(Uri.parse('$_baseUrl$path'), headers: _headers));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['data'] as List<dynamic>? ?? [];
    }
    throw _error(res);
  }

  Future<Map<String, dynamic>> getOne(String path) async {
    final res = await _request(() => http.get(Uri.parse('$_baseUrl$path'), headers: _headers));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>? ?? body;
    }
    throw _error(res);
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final res = await _request(
        () => http.post(Uri.parse('$_baseUrl$path'), headers: _headers, body: body != null ? jsonEncode(body) : null));
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 || res.statusCode == 201) return decoded;
    throw _error(res, decoded['message'] as String?);
  }

  Exception _error(http.Response res, [String? msg]) =>
      Exception(msg ?? 'Lỗi kết nối server (${res.statusCode})');
}
