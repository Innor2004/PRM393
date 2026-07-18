import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/backend_service.dart';
import '../services/offline_database_service.dart';

class QuizProvider extends ChangeNotifier {
  final BackendService _backend = BackendService();
  final OfflineDatabaseService _offlineDb = OfflineDatabaseService();

  int _userId = 1;
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

  void setUserId(int id) {
    _userId = id;
  }

  Future<void> loadQuestions(int lessonId) async {
    _isLoading = true;
    _reset();
    notifyListeners();

    final isSupportedDb = !kIsWeb;

    try {
      final data = await _backend.getList('/lessons/$lessonId/questions');
      _questions = data.map((j) => Question.fromJson(Map<String, dynamic>.from(j))).toList();
      // Cache questions locally if supported
      if (isSupportedDb) {
        await _offlineDb.saveQuestions(_questions);
      }
    } catch (e) {
      debugPrint('loadQuestions online error: $e');
      if (isSupportedDb) {
        debugPrint('loading from local DB');
        try {
          _questions = await _offlineDb.getQuestionsForLesson(lessonId);
        } catch (dbError) {
          debugPrint('loadQuestions offline DB error: $dbError');
          _questions = [];
        }
      } else {
        _questions = [];
      }
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

    final isSupportedDb = !kIsWeb;

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
      debugPrint('submitToBackend online error: $e, computing score locally');
      _correctCount = 0;
      for (int i = 0; i < _questions.length; i++) {
        final userAnswer = _answers[i];
        if (userAnswer == _questions[i].correctOption) {
          _correctCount++;
        }
      }
      _isSubmitted = true;

      final localScore = score;

      if (isSupportedDb) {
        debugPrint('queuing sync');
        try {
          await _offlineDb.addPendingSync(
            userId: _userId,
            lessonId: lessonId,
            type: 'quiz_submit',
            payload: {
              'lessonId': lessonId,
              'answers': answers,
            },
          );
          debugPrint('Successfully queued offline quiz submission for lesson $lessonId');
        } catch (dbError) {
          debugPrint('Failed to queue offline quiz submission: $dbError');
        }
      }

      notifyListeners();
      return localScore;
    }
  }

  Future<bool> hasQuestions(int lessonId) async {
    final isSupportedDb = !kIsWeb;

    try {
      final data = await _backend.getList('/lessons/$lessonId/questions');
      return data.isNotEmpty;
    } catch (_) {
      if (isSupportedDb) {
        try {
          final localQ = await _offlineDb.getQuestionsForLesson(lessonId);
          return localQ.isNotEmpty;
        } catch (_) {
          return false;
        }
      }
      return false;
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
