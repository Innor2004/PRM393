import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/badge.dart';

void main() {
  group('Badge.fromJson', () {
    test('tạo Badge đúng với đầy đủ field', () {
      final json = {
        'id': 1,
        'name': 'Nhà vật lý',
        'description': 'Hoàn thành tất cả bài học với điểm trung bình từ 9.0 trở lên',
        'iconUrl': '🏆',
        'earnedAt': '2026-07-15T10:30:00Z',
      };

      final badge = Badge.fromJson(json);

      expect(badge.id, 1);
      expect(badge.name, 'Nhà vật lý');
      expect(badge.description, contains('9.0'));
      expect(badge.iconUrl, '🏆');
      expect(badge.earnedAt, isNotNull);
      expect(badge.earnedAt!.year, 2026);
    });

    test('tạo Badge với earnedAt = null', () {
      final json = {
        'id': 2,
        'name': 'Học sinh chăm chỉ',
        'description': null,
        'iconUrl': '⭐',
      };

      final badge = Badge.fromJson(json);

      expect(badge.id, 2);
      expect(badge.name, 'Học sinh chăm chỉ');
      expect(badge.description, isNull);
      expect(badge.iconUrl, '⭐');
      expect(badge.earnedAt, isNull);
    });
  });
}
