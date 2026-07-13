import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import '../services/backend_service.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final BackendService _backend = BackendService();

  List<Question> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  final Map<int, String> _answers = {};
  bool _isSubmitted = false;
  int _correctCount = 0;
  bool _useBackend = false;
  bool _isLoading = false;

  bool get useBackend => _useBackend;
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
    _useBackend = _backend.isAvailable;
    _reset();
    notifyListeners();

    if (_useBackend) {
      try {
        final data = await _backend.getList('/lessons/$lessonId/questions');
        _questions = data.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
      } catch (_) {
        _questions = _api.getQuestions(lessonId);
      }
    } else {
      _questions = _api.getQuestions(lessonId);
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

  void submitQuiz() {
    if (_selectedAnswer != null) {
      _answers[_currentIndex] = _selectedAnswer!;
    }
    _correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      final userAnswer = _answers[i];
      if (userAnswer == _questions[i].correctOption) {
        _correctCount++;
      }
    }
    _isSubmitted = true;
    notifyListeners();
  }

  Future<double> submitToBackend(int lessonId) async {
    if (!_useBackend) {
      submitQuiz();
      return score;
    }

    final answers = _answers.entries.map((e) => {
      'question_id': _questions[e.key].id,
      'selected_option': e.value,
    }).toList();

    try {
      final res = await _backend.post('/quiz/submit', body: {
        'lesson_id': lessonId,
        'answers': answers,
      });
      _correctCount = res['correct_count'] as int? ?? _correctCount;
      _isSubmitted = true;
      notifyListeners();
      return (res['score'] as num?)?.toDouble() ?? score;
    } catch (_) {
      submitQuiz();
      return score;
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
