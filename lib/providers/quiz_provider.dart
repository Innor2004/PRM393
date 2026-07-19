import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';
import '../services/backend_service.dart';

class QuizProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();

  List<Question> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  final Map<int, String> _answers = {};
  bool _isSubmitted = false;
  int _correctCount = 0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  String? get selectedAnswer => _selectedAnswer;
  bool get isSubmitted => _isSubmitted;
  int get correctCount => _correctCount;
  double get score => _questions.isEmpty ? 0 : (_correctCount / _questions.length) * 10;

  Future<void> loadQuestions(int lessonId) async {
    _isLoading = true;
    _reset();
    notifyListeners();

    try {
      final data = await _backend.getList('/lessons/$lessonId/questions');
      _questions = data.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('loadQuestions error: $e');
      _questions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_isSubmitted) return;
    _selectedAnswer = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (_selectedAnswer != null) {
      _answers[_currentIndex] = _selectedAnswer!;
    }
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswer = _answers[_currentIndex];
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      if (_selectedAnswer != null) {
        _answers[_currentIndex] = _selectedAnswer!;
      }
      _currentIndex--;
      _selectedAnswer = _answers[_currentIndex];
      notifyListeners();
    }
  }

  Future<double> submitToBackend(int lessonId) async {
    if (_selectedAnswer != null) {
      _answers[_currentIndex] = _selectedAnswer!;
    }

    final answers = _answers.entries.map((e) => {
      'questionId': _questions[e.key].id,
      'selectedOption': e.value,
    }).toList();

    try {
      final res = await _backend.post('/quiz/submit', body: {
        'lessonId': lessonId,
        'answers': answers,
      });
      _correctCount = res['correctCount'] as int? ?? 0;
      _isSubmitted = true;
      notifyListeners();
      return (res['score'] as num?)?.toDouble() ?? score;
    } catch (e) {
      debugPrint('submitToBackend error: $e');
      _correctCount = 0;
      for (int i = 0; i < _questions.length; i++) {
        final userAnswer = _answers[i];
        if (userAnswer == _questions[i].correctOption) {
          _correctCount++;
        }
      }
      _isSubmitted = true;
      notifyListeners();
      return score;
    }
  }

  Future<bool> hasQuestions(int lessonId) async {
    try {
      final data = await _backend.getList('/lessons/$lessonId/questions');
      return data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<QuizAttempt>> getQuizHistory(int lessonId) async {
    try {
      final data = await _backend.getList('/quiz/history/$lessonId');
      return data.map((j) => QuizAttempt.fromJson(Map<String, dynamic>.from(j))).toList();
    } catch (e) {
      debugPrint('getQuizHistory error: $e');
      return [];
    }
  }

  void reset() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _questions = [];
    _currentIndex = 0;
    _selectedAnswer = null;
    _answers.clear();
    _isSubmitted = false;
    _correctCount = 0;
  }

  bool isAnswerCorrect(int index) {
    if (!_isSubmitted) return false;
    return _answers[index] == _questions[index].correctOption;
  }

  bool hasAnswered(int index) => _answers.containsKey(index);
}
