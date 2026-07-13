import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  static final BackendService _instance =
  BackendService._internal();

  factory BackendService() => _instance;

  BackendService._internal();

  static const String _baseUrlKey = 'backend_base_url';
  String _baseUrl = 'http://localhost:5271/api';
  String? _token;
  bool _isAvailable = false;

  String get baseUrl => _baseUrl;

  String? get token => _token;

  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultUrl = _getDefaultBaseUrl();

    if (kIsWeb) {
      // Chrome Web sử dụng localhost.
      _baseUrl = defaultUrl;

      // Ghi đè địa chỉ cũ như 10.0.2.2 đang lưu trong Chrome.
      await prefs.setString(
        _baseUrlKey,
        _baseUrl,
      );
    } else {
      _baseUrl =
          prefs.getString(_baseUrlKey) ?? defaultUrl;
    }

    _baseUrl = _normalizeBaseUrl(_baseUrl);

    debugPrint('Backend URL: $_baseUrl');
  }

  String _getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5271/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5271/api';
    }

    return 'http://localhost:5271/api';
  }

  String _normalizeBaseUrl(String url) {
    var result = url.trim();

    while (result.endsWith('/')) {
      result = result.substring(
        0,
        result.length - 1,
      );
    }

    return result;
  }

  Future<void> setBaseUrl(String url) async {
    final cleanUrl = _normalizeBaseUrl(url);

    if (cleanUrl.isEmpty) {
      throw Exception(
        'Địa chỉ backend không được để trống',
      );
    }

    _baseUrl = cleanUrl;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _baseUrlKey,
      _baseUrl,
    );

    debugPrint('Backend URL changed: $_baseUrl');
  }

  Future<bool> checkHealth() async {
    _isAvailable = false;

    try {
      final url = _buildUri('/health');

      debugPrint('Checking backend: $url');

      final response = await http
          .get(url)
          .timeout(
        const Duration(seconds: 5),
      );

      debugPrint(
        'Backend health status: ${response.statusCode}',
      );

      debugPrint(
        'Backend health body: ${response.body}',
      );

      _isAvailable =
          response.statusCode >= 200 &&
              response.statusCode < 300;

      return _isAvailable;
    } on TimeoutException {
      debugPrint(
        'Backend health error: Request timeout',
      );
      _isAvailable = false;

      return false;
    } catch (error) {
      debugPrint(
        'Backend health error: $error',
      );

      _isAvailable = false;

      return false;
    }
  }

  void setToken(String? token) {
    _token = token;

    debugPrint(
      token == null
          ? 'Backend token cleared'
          : 'Backend token updated',
    );
  }

  Uri _buildUri(String path) {
    final cleanPath = path.startsWith('/')
        ? path
        : '/$path';

    return Uri.parse(
      '$_baseUrl$cleanPath',
    );
  }

  Map<String, String> get _jsonHeaders {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  Map<String, String> get _multipartHeaders {
    return {
      'Accept': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  Future<http.Response> _send(
      Future<http.Response> Function() request,
      ) async {
    try {
      return await request().timeout(
        const Duration(seconds: 15),
      );
    } on TimeoutException {
      throw Exception(
        'Kết nối backend quá thời gian. '
            'Hãy kiểm tra backend đang chạy.',
      );
    } catch (error) {
      throw Exception(
        'Không thể kết nối backend: $error',
      );
    }
  }

  Future<List<dynamic>> getList(
      String path,
      ) async {
    final response = await _send(
          () => http.get(
        _buildUri(path),
        headers: _jsonHeaders,
      ),
    );

    if (!_isSuccess(response.statusCode)) {
      throw _createError(response);
    }

    final decoded = _decodeBody(response);

    if (decoded is List<dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is List<dynamic>) {
        return data;
      }
    }

    return [];
  }

  Future<Map<String, dynamic>> getOne(
      String path,
      ) async {
    final response = await _send(
          () => http.get(
        _buildUri(path),
        headers: _jsonHeaders,
      ),
    );

    if (!_isSuccess(response.statusCode)) {
      throw _createError(response);
    }

    final decoded = _decodeBody(response);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      return decoded;
    }

    throw Exception(
      'Dữ liệu backend trả về '
          'không đúng định dạng object',
    );
  }

  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final response = await _send(
          () => http.post(
        _buildUri(path),
        headers: _jsonHeaders,
        body: body == null
            ? null
            : jsonEncode(body),
      ),
    );

    return _handleObjectResponse(response);
  }

  Future<Map<String, dynamic>> put(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final response = await _send(
          () => http.put(
        _buildUri(path),
        headers: _jsonHeaders,
        body: body == null
            ? null
            : jsonEncode(body),
      ),
    );

    return _handleObjectResponse(response);
  }

  Future<Map<String, dynamic>> patch(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final response = await _send(
          () => http.patch(
        _buildUri(path),
        headers: _jsonHeaders,
        body: body == null
            ? null
            : jsonEncode(body),
      ),
    );

    return _handleObjectResponse(response);
  }

  Future<Map<String, dynamic>> delete(
      String path,
      ) async {
    final response = await _send(
          () => http.delete(
        _buildUri(path),
        headers: _jsonHeaders,
      ),
    );

    return _handleObjectResponse(response);
  }

  /// Upload ảnh trên Android, Windows, macOS và Linux.
  ///
  /// Chrome Web không gọi hàm này.
  Future<Map<String, dynamic>> uploadFile(
      String path, {
        required String filePath,
        String fieldName = 'avatar',
      }) async {
    if (filePath.trim().isEmpty) {
      throw Exception(
        'Không tìm thấy đường dẫn ảnh',
      );
    }

    final fileName = _getFileNameFromPath(filePath);

    final mediaType = _getImageMediaType(
      fileName,
    );

    try {
      final request = http.MultipartRequest(
        'POST',
        _buildUri(path),
      );

      request.headers.addAll(
        _multipartHeaders,
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          filePath,
          filename: fileName,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(
        const Duration(seconds: 30),
      );

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      return _handleObjectResponse(response);
    } on TimeoutException {
      throw Exception(
        'Tải ảnh quá thời gian. Vui lòng thử lại.',
      );
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      throw Exception(message);
    }
  }

  /// Upload ảnh trên Chrome Web.
  ///
  /// Web phải gửi dữ liệu bằng bytes thay vì đường dẫn file.
  Future<Map<String, dynamic>> uploadBytes(
      String path, {
        required List<int> bytes,
        required String fileName,
        String fieldName = 'avatar',
      }) async {
    if (bytes.isEmpty) {
      throw Exception(
        'Dữ liệu ảnh đang trống',
      );
    }

    final mediaType = _getImageMediaType(
      fileName,
      bytes: bytes,
    );

    final safeFileName = _ensureImageExtension(
      fileName,
      mediaType,
    );

    debugPrint(
      'Uploading avatar: '
          '$safeFileName, '
          '${mediaType.type}/${mediaType.subtype}, '
          '${bytes.length} bytes',
    );

    try {
      final request = http.MultipartRequest(
        'POST',
        _buildUri(path),
      );

      request.headers.addAll(
        _multipartHeaders,
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: safeFileName,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(
        const Duration(seconds: 30),
      );

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      return _handleObjectResponse(response);
    } on TimeoutException {
      throw Exception(
        'Tải ảnh quá thời gian. Vui lòng thử lại.',
      );
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      throw Exception(message);
    }
  }

  /// Xác định Content-Type của ảnh.
  ///
  /// Backend yêu cầu:
  /// image/jpeg
  /// image/png
  /// image/webp
  MediaType _getImageMediaType(
      String fileName, {
        List<int>? bytes,
      }) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg')) {
      return MediaType(
        'image',
        'jpeg',
      );
    }

    if (lowerName.endsWith('.png')) {
      return MediaType(
        'image',
        'png',
      );
    }

    if (lowerName.endsWith('.webp')) {
      return MediaType(
        'image',
        'webp',
      );
    }

    // Trường hợp Flutter Web không trả đúng phần mở rộng,
    // kiểm tra chữ ký của file bằng bytes.
    if (bytes != null) {
      if (_isJpeg(bytes)) {
        return MediaType(
          'image',
          'jpeg',
        );
      }

      if (_isPng(bytes)) {
        return MediaType(
          'image',
          'png',
        );
      }

      if (_isWebp(bytes)) {
        return MediaType(
          'image',
          'webp',
        );
      }
    }

    throw Exception(
      'Chỉ hỗ trợ ảnh JPG, JPEG, PNG hoặc WEBP',
    );
  }

  bool _isJpeg(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  bool _isPng(List<int> bytes) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  bool _isWebp(List<int> bytes) {
    return bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
  }

  String _ensureImageExtension(
      String fileName,
      MediaType mediaType,
      ) {
    var cleanName = fileName.trim();

    if (cleanName.isEmpty) {
      cleanName = 'avatar';
    }

    final lowerName = cleanName.toLowerCase();

    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp')) {
      return cleanName;
    }

    switch (mediaType.subtype) {
      case 'png':
        return '$cleanName.png';

      case 'webp':
        return '$cleanName.webp';

      case 'jpeg':
      default:
        return '$cleanName.jpg';
    }
  }

  String _getFileNameFromPath(
      String filePath,
      ) {
    final parts = filePath.split(
      RegExp(r'[\\/]'),
    );

    return parts.isEmpty
        ? 'avatar.jpg'
        : parts.last;
  }

  Map<String, dynamic> _handleObjectResponse(
      http.Response response,
      ) {
    if (!_isSuccess(response.statusCode)) {
      throw _createError(response);
    }

    if (response.statusCode == 204 ||
        response.body.trim().isEmpty) {
      return {};
    }

    final decoded = _decodeBody(response);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      return decoded;
    }

    throw Exception(
      'Dữ liệu backend trả về '
          'không đúng định dạng',
    );
  }

  dynamic _decodeBody(
      http.Response response,
      ) {
    final body = response.body.trim();

    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception(
        'Backend trả về dữ liệu '
            'không hợp lệ: $body',
      );
    }
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 &&
        statusCode < 300;
  }

  Exception _createError(
      http.Response response,
      ) {
    var message =
        'Lỗi backend (${response.statusCode})';

    final body = response.body.trim();

    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          final serverMessage =
              decoded['message'] ??
                  decoded['error'] ??
                  decoded['title'];

          if (serverMessage != null) {
            message = serverMessage.toString();
          }
        }
      } catch (_) {
        message =
        'Lỗi backend '
            '(${response.statusCode}): $body';
      }
    }

    if (response.statusCode == 401) {
      final requestPath = response.request?.url.path ?? '';
      final isAuthEndpoint = requestPath.endsWith('/auth/login') || requestPath.endsWith('/auth/register');
      if (!isAuthEndpoint) {
        message =
        'Phiên đăng nhập đã hết hạn. '
            'Vui lòng đăng nhập lại.';
      }
    }

    if (response.statusCode == 403) {
      message =
      'Bạn không có quyền thực hiện chức năng này.';
    }

    if (response.statusCode == 404) {
      message =
      'Không tìm thấy API hoặc dữ liệu.';
    }

    if (response.statusCode >= 500) {
      message =
      'Backend đang gặp lỗi. '
          'Hãy kiểm tra Terminal backend.';
    }

    return Exception(message);
  }
}