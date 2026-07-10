import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._();
  factory LocalStorageService() => _instance;
  LocalStorageService._();

  Future<File> _localFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name.json');
  }

  Future<void> saveData(String key, dynamic data) async {
    final file = await _localFile(key);
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> loadData(String key) async {
    final file = await _localFile(key);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  Future<bool> hasData(String key) async {
    final file = await _localFile(key);
    return file.exists();
  }

  Future<void> removeData(String key) async {
    final file = await _localFile(key);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
