import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/question.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  // Mock data
  final List<Chapter> _chapters = [
    Chapter(id: 1, bookId: 1, title: 'Động học chất điểm', description: 'Chuyển động thẳng đều, biến đổi đều, rơi tự do', orderIndex: 1),
    Chapter(id: 2, bookId: 1, title: 'Động lực học chất điểm', description: 'Lực, khối lượng, định luật Newton', orderIndex: 2),
    Chapter(id: 3, bookId: 1, title: 'Cân bằng và chuyển động của vật rắn', description: 'Mô men lực, điều kiện cân bằng', orderIndex: 3),
    Chapter(id: 4, bookId: 1, title: 'Công và năng lượng', description: 'Công, động năng, thế năng, định luật bảo toàn', orderIndex: 4),
  ];

  final Map<int, List<Lesson>> _chapterLessons = {
    1: [
      Lesson(id: 1, chapterId: 1, title: 'Chuyển động thẳng đều', orderIndex: 1, estimatedMinutes: 20,
          contentBody: '''
# Bài 1: Chuyển động thẳng đều

## 1. Định nghĩa
Chuyển động thẳng đều là chuyển động có quỹ đạo là đường thẳng và có vận tốc không đổi theo thời gian.

## 2. Phương trình chuyển động
`x = x₀ + v·t`

Trong đó:
- x: tọa độ tại thời điểm t (m)
- x₀: tọa độ ban đầu (m)
- v: vận tốc (m/s)
- t: thời gian (s)

## 3. Đồ thị tọa độ - thời gian
Đồ thị tọa độ - thời gian của chuyển động thẳng đều là một đường thẳng xiên góc.

## 4. Công thức tính quãng đường
`s = v·t`

## 5. Ví dụ
Một xe chạy với vận tốc 15 m/s. Tính quãng đường xe đi được trong 10 giây.
Giải: `s = v·t = 15·10 = 150 m`
'''),
      Lesson(id: 2, chapterId: 1, title: 'Chuyển động thẳng biến đổi đều', orderIndex: 2, estimatedMinutes: 25,
          contentBody: '''
# Bài 2: Chuyển động thẳng biến đổi đều

## 1. Định nghĩa
Chuyển động thẳng biến đổi đều là chuyển động có quỹ đạo là đường thẳng và có gia tốc không đổi.

## 2. Gia tốc
`a = (v - v₀) / t`

Đơn vị: m/s²

## 3. Các phương trình
- Vận tốc: `v = v₀ + a·t`
- Tọa độ: `x = x₀ + v₀·t + ½·a·t²`
- Công thức độc lập với thời gian: `v² - v₀² = 2·a·s`

## 4. Chuyển động nhanh dần đều và chậm dần đều
- Nhanh dần đều: a × v > 0
- Chậm dần đều: a × v < 0
'''),
      Lesson(id: 3, chapterId: 1, title: 'Sự rơi tự do', orderIndex: 3, estimatedMinutes: 15,
          contentBody: '''
# Bài 3: Sự rơi tự do

## 1. Định nghĩa
Sự rơi tự do là sự rơi chỉ dưới tác dụng của trọng lực.

## 2. Đặc điểm
- Phương thẳng đứng
- Chiều từ trên xuống dưới
- Chuyển động nhanh dần đều
- Gia tốc: g ≈ 9.8 m/s²

## 3. Công thức
- `v = g·t`
- `h = ½·g·t²`
- `v² = 2·g·h`
'''),
    ],
    2: [
      Lesson(id: 4, chapterId: 2, title: 'Lực và khối lượng', orderIndex: 1, estimatedMinutes: 20,
          contentBody: '''
# Bài 4: Lực và khối lượng

## 1. Khái niệm lực
Lực là đại lượng vectơ đặc trưng cho tác dụng của vật này lên vật khác, gây ra gia tốc hoặc biến dạng.

## 2. Tổng hợp lực
Tổng hợp lực là thay thế nhiều lực bằng một lực có tác dụng tương đương.

F = F₁ + F₂ (tổng vectơ)

## 3. Phân tích lực
Phân tích lực là thay thế một lực bằng hai lực tác dụng theo hai phương xác định.
'''),
      Lesson(id: 5, chapterId: 2, title: 'Định luật I Newton', orderIndex: 2, estimatedMinutes: 15,
          contentBody: '''
# Bài 5: Định luật I Newton

## Nội dung định luật
Một vật đang đứng yên sẽ tiếp tục đứng yên, đang chuyển động sẽ tiếp tục chuyển động thẳng đều, nếu không chịu tác dụng của lực nào hoặc chịu tác dụng của các lực cân bằng.

## Quán tính
Quán tính là tính chất bảo toàn trạng thái chuyển động của vật.
'''),
      Lesson(id: 6, chapterId: 2, title: 'Định luật II Newton', orderIndex: 3, estimatedMinutes: 20,
          contentBody: '''
# Bài 6: Định luật II Newton

## Nội dung định luật
Gia tốc của một vật cùng hướng với lực tác dụng lên vật. Độ lớn của gia tốc tỉ lệ thuận với độ lớn của lực và tỉ lệ nghịch với khối lượng của vật.

## Công thức
`F = m·a`

Trong đó:
- F: lực tác dụng (N)
- m: khối lượng (kg)
- a: gia tốc (m/s²)
'''),
    ],
    3: [
      Lesson(id: 7, chapterId: 3, title: 'Mô men lực', orderIndex: 1, estimatedMinutes: 20,
          contentBody: '''
# Bài 7: Mô men lực

## 1. Định nghĩa
Mô men lực là đại lượng đặc trưng cho tác dụng làm quay của lực.

## 2. Công thức
`M = F·d`

Trong đó:
- M: mô men lực (N·m)
- F: lực tác dụng (N)
- d: cánh tay đòn (m)

## 3. Quy tắc mô men
Muốn cho vật rắn cân bằng, tổng các mô men lực có xu hướng quay theo chiều kim đồng hồ bằng tổng các mô men lực có xu hướng quay ngược chiều kim đồng hồ.
'''),
      Lesson(id: 8, chapterId: 3, title: 'Điều kiện cân bằng của vật rắn', orderIndex: 2, estimatedMinutes: 20,
          contentBody: '''
# Bài 8: Điều kiện cân bằng của vật rắn

## 1. Cân bằng của vật rắn chịu tác dụng của hai lực
Vật rắn cân bằng khi hai lực cùng giá, cùng độ lớn, ngược chiều.

## 2. Cân bằng của vật rắn chịu tác dụng của ba lực
Ba lực phải đồng phẳng, đồng quy và hợp lực của hai lực cân bằng với lực thứ ba.
'''),
    ],
    4: [
      Lesson(id: 9, chapterId: 4, title: 'Công cơ học', orderIndex: 1, estimatedMinutes: 15,
          contentBody: '''
# Bài 9: Công cơ học

## 1. Định nghĩa
Công cơ học là đại lượng đặc trưng cho tác dụng của lực làm vật di chuyển.

## 2. Công thức
`A = F·s·cos(α)`

Trong đó:
- A: công cơ học (J)
- F: lực tác dụng (N)
- s: quãng đường (m)
- α: góc giữa lực và hướng chuyển động

## 3. Công phát động và công cản
- Công phát động: α < 90° → A > 0
- Công cản: α > 90° → A < 0
'''),
      Lesson(id: 10, chapterId: 4, title: 'Động năng và thế năng', orderIndex: 2, estimatedMinutes: 20,
          contentBody: '''
# Bài 10: Động năng và thế năng

## 1. Động năng
Động năng là năng lượng mà vật có được do chuyển động.

`Wđ = ½·m·v²`

## 2. Thế năng trọng trường
`Wt = m·g·h`

## 3. Định lý động năng
Độ biến thiên động năng bằng tổng công của ngoại lực.

ΔWđ = A
'''),
      Lesson(id: 11, chapterId: 4, title: 'Định luật bảo toàn cơ năng', orderIndex: 3, estimatedMinutes: 20,
          contentBody: '''
# Bài 11: Định luật bảo toàn cơ năng

## 1. Cơ năng
Cơ năng = Động năng + Thế năng
`W = Wđ + Wt = ½·m·v² + m·g·h`

## 2. Định luật bảo toàn cơ năng
Khi vật chỉ chịu tác dụng của trọng lực và lực đàn hồi (lực thế), cơ năng của vật được bảo toàn.

W₁ = W₂ = const

## 3. Ứng dụng
Vật rơi tự do: thế năng giảm, động năng tăng, cơ năng không đổi.
'''),
    ],
  };

  final Map<int, List<Question>> _lessonQuestions = {
    1: [
      Question(id: 1, lessonId: 1, questionText: 'Chuyển động thẳng đều là chuyển động có:',
          optionA: 'Quỹ đạo là đường thẳng, vận tốc không đổi',
          optionB: 'Quỹ đạo là đường cong, vận tốc không đổi',
          optionC: 'Quỹ đạo là đường thẳng, vận tốc thay đổi',
          optionD: 'Quỹ đạo là đường cong, vận tốc thay đổi',
          correctOption: 'A',
          explanation: 'Chuyển động thẳng đều có quỹ đạo là đường thẳng và vận tốc không đổi theo thời gian.'),
      Question(id: 2, lessonId: 1, questionText: 'Công thức tính quãng đường trong chuyển động thẳng đều là:',
          optionA: 's = v/t', optionB: 's = v × t', optionC: 's = v² × t', optionD: 's = t/v',
          correctOption: 'B',
          explanation: 'Quãng đường s = v × t, trong đó v là vận tốc, t là thời gian.'),
      Question(id: 3, lessonId: 1, questionText: 'Đồ thị tọa độ - thời gian của chuyển động thẳng đều là:',
          optionA: 'Đường thẳng song song trục thời gian',
          optionB: 'Đường thẳng xiên góc',
          optionC: 'Đường parabol',
          optionD: 'Đường hypebol',
          correctOption: 'B',
          explanation: 'Đồ thị tọa độ - thời gian là đường thẳng xiên góc, độ dốc bằng vận tốc.'),
    ],
    2: [
      Question(id: 4, lessonId: 2, questionText: 'Gia tốc của chuyển động thẳng biến đổi đều:',
          optionA: 'Thay đổi theo thời gian',
          optionB: 'Không đổi',
          optionC: 'Tỉ lệ với vận tốc',
          optionD: 'Tỉ lệ với thời gian',
          correctOption: 'B',
          explanation: 'Trong chuyển động thẳng biến đổi đều, gia tốc không đổi theo thời gian.'),
      Question(id: 5, lessonId: 2, questionText: 'Công thức vận tốc trong chuyển động thẳng biến đổi đều:',
          optionA: 'v = v₀ + a×t', optionB: 'v = v₀ - a×t',
          optionC: 'v = v₀ + (1/2)×a×t²', optionD: 'v = v₀² + 2×a×s',
          correctOption: 'A',
          explanation: 'Công thức v = v₀ + a×t là công thức vận tốc của chuyển động thẳng biến đổi đều.'),
    ],
    3: [
      Question(id: 6, lessonId: 3, questionText: 'Gia tốc rơi tự do trên Trái Đất xấp xỉ:',
          optionA: '9.8 m/s²', optionB: '4.9 m/s²', optionC: '19.6 m/s²', optionD: '0 m/s²',
          correctOption: 'A',
          explanation: 'Gia tốc rơi tự do trên Trái Đất là g ≈ 9.8 m/s².'),
    ],
    4: [
      Question(id: 7, lessonId: 4, questionText: 'Lực là đại lượng:',
          optionA: 'Vô hướng', optionB: 'Vectơ',
          optionC: 'Tensơ', optionD: 'Hằng số',
          correctOption: 'B',
          explanation: 'Lực là đại lượng vectơ, có độ lớn, phương, chiều và điểm đặt.'),
    ],
    5: [
      Question(id: 8, lessonId: 5, questionText: 'Định luật I Newton còn gọi là:',
          optionA: 'Định luật quán tính', optionB: 'Định luật gia tốc',
          optionC: 'Định luật phản lực', optionD: 'Định luật hấp dẫn',
          correctOption: 'A',
          explanation: 'Định luật I Newton còn gọi là định luật quán tính.'),
    ],
    6: [
      Question(id: 9, lessonId: 6, questionText: 'Công thức của định luật II Newton là:',
          optionA: 'F = m/a', optionB: 'F = m × a',
          optionC: 'F = m + a', optionD: 'F = m - a',
          correctOption: 'B',
          explanation: 'Định luật II Newton: F = m × a, gia tốc cùng hướng với lực.'),
    ],
    7: [
      Question(id: 10, lessonId: 7, questionText: 'Đơn vị của mô men lực là:',
          optionA: 'N.m', optionB: 'N/m', optionC: 'N.s', optionD: 'N/kg',
          correctOption: 'A',
          explanation: 'Mô men lực có đơn vị là N.m (Newton mét).'),
    ],
    9: [
      Question(id: 11, lessonId: 9, questionText: 'Đơn vị của công cơ học là:',
          optionA: 'Watt (W)', optionB: 'Joule (J)',
          optionC: 'Newton (N)', optionD: 'Pascal (Pa)',
          correctOption: 'B',
          explanation: 'Công cơ học có đơn vị là Joule (J).'),
    ],
    11: [
      Question(id: 12, lessonId: 11, questionText: 'Khi vật rơi tự do, cơ năng:',
          optionA: 'Tăng dần', optionB: 'Giảm dần',
          optionC: 'Không đổi', optionD: 'Bằng 0',
          correctOption: 'C',
          explanation: 'Khi vật rơi tự do, thế năng chuyển hóa thành động năng, cơ năng bảo toàn.'),
    ],
  };

  List<Chapter> getChapters() => _chapters;

  int _nextChapterId() => _chapters.fold(0, (max, c) => c.id > max ? c.id : max) + 1;

  void addChapter(String title, String? description) {
    final id = _nextChapterId();
    final orderIndex = _chapters.length + 1;
    _chapters.add(Chapter(id: id, bookId: 1, title: title, description: description, orderIndex: orderIndex));
    _chapterLessons[id] = [];
  }

  void updateChapter(int id, String title, String? description) {
    final i = _chapters.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _chapters[i] = _chapters[i].copyWith(title: title, description: description);
  }

  void deleteChapter(int id) {
    _chapters.removeWhere((c) => c.id == id);
    _chapterLessons.remove(id);
  }

  List<Lesson> getLessons(int chapterId) =>
      _chapterLessons[chapterId] ?? [];

  Lesson? getLesson(int lessonId) {
    for (final lessons in _chapterLessons.values) {
      for (final lesson in lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  int _nextLessonId(int chapterId) {
    final lessons = _chapterLessons[chapterId] ?? [];
    return lessons.fold(0, (max, l) => l.id > max ? l.id : max) + 1;
  }

  void addLesson(int chapterId, String title, {int estimatedMinutes = 15, String? contentBody}) {
    final lessons = _chapterLessons.putIfAbsent(chapterId, () => []);
    final id = _nextLessonId(chapterId);
    final orderIndex = lessons.length + 1;
    lessons.add(Lesson(id: id, chapterId: chapterId, title: title, orderIndex: orderIndex, estimatedMinutes: estimatedMinutes, contentBody: contentBody));
  }

  void updateLesson(int id, int chapterId, String title, {int? estimatedMinutes, String? contentBody}) {
    final lessons = _chapterLessons[chapterId];
    if (lessons == null) return;
    final i = lessons.indexWhere((l) => l.id == id);
    if (i == -1) return;
    lessons[i] = lessons[i].copyWith(title: title, estimatedMinutes: estimatedMinutes, contentBody: contentBody);
  }

  void deleteLesson(int chapterId, int lessonId) {
    final lessons = _chapterLessons[chapterId];
    if (lessons == null) return;
    lessons.removeWhere((l) => l.id == lessonId);
    _lessonQuestions.remove(lessonId);
  }

  List<Question> getQuestions(int lessonId) =>
      _lessonQuestions[lessonId] ?? [];

  int _nextQuestionId(int lessonId) {
    final questions = _lessonQuestions[lessonId] ?? [];
    return questions.fold(0, (max, q) => q.id > max ? q.id : max) + 1;
  }

  void addQuestion(int lessonId, String questionText, String optionA, String optionB, String optionC, String optionD, String correctOption, {String? explanation}) {
    final questions = _lessonQuestions.putIfAbsent(lessonId, () => []);
    final id = _nextQuestionId(lessonId);
    questions.add(Question(id: id, lessonId: lessonId, questionText: questionText, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, correctOption: correctOption, explanation: explanation));
  }

  void updateQuestion(int id, int lessonId, String questionText, String optionA, String optionB, String optionC, String optionD, String correctOption, {String? explanation}) {
    final questions = _lessonQuestions[lessonId];
    if (questions == null) return;
    final i = questions.indexWhere((q) => q.id == id);
    if (i == -1) return;
    questions[i] = questions[i].copyWith(questionText: questionText, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, correctOption: correctOption, explanation: explanation);
  }

  void deleteQuestion(int lessonId, int questionId) {
    final questions = _lessonQuestions[lessonId];
    if (questions == null) return;
    questions.removeWhere((q) => q.id == questionId);
  }
}
