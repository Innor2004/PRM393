class QuizAttempt {
  final int id;
  final int lessonId;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final DateTime createdAt;
  final List<QuizAttemptDetail> details;

  QuizAttempt({
    required this.id,
    required this.lessonId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.createdAt,
    required this.details,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      lessonId: json['lessonId'],
      score: (json['score'] as num).toDouble(),
      correctCount: json['correctCount'],
      totalQuestions: json['totalQuestions'],
      createdAt: DateTime.parse(json['createdAt']),
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => QuizAttemptDetail.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class QuizAttemptDetail {
  final int id;
  final int questionId;
  final String questionText;
  final String? selectedOption;
  final String correctOption;
  final bool isCorrect;
  final String? explanation;

  QuizAttemptDetail({
    required this.id,
    required this.questionId,
    required this.questionText,
    this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    this.explanation,
  });

  factory QuizAttemptDetail.fromJson(Map<String, dynamic> json) {
    return QuizAttemptDetail(
      id: json['id'],
      questionId: json['questionId'],
      questionText: json['questionText'],
      selectedOption: json['selectedOption'],
      correctOption: json['correctOption'],
      isCorrect: json['isCorrect'],
      explanation: json['explanation'],
    );
  }
}
