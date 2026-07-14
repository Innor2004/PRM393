class Question {
  final int id;
  final int lessonId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String? explanation;

  Question({
    required this.id,
    required this.lessonId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        lessonId: json['lessonId'] as int? ?? json['lesson_id'] as int,
        questionText: json['questionText'] as String? ?? json['question_text'] as String,
        optionA: json['optionA'] as String? ?? json['option_a'] as String,
        optionB: json['optionB'] as String? ?? json['option_b'] as String,
        optionC: json['optionC'] as String? ?? json['option_c'] as String,
        optionD: json['optionD'] as String? ?? json['option_d'] as String,
        correctOption: json['correctOption'] as String? ?? json['correct_option'] as String,
        explanation: json['explanation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'questionText': questionText,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctOption': correctOption,
        'explanation': explanation,
      };

  Question copyWith({
    int? id,
    int? lessonId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctOption,
    String? explanation,
  }) =>
      Question(
        id: id ?? this.id,
        lessonId: lessonId ?? this.lessonId,
        questionText: questionText ?? this.questionText,
        optionA: optionA ?? this.optionA,
        optionB: optionB ?? this.optionB,
        optionC: optionC ?? this.optionC,
        optionD: optionD ?? this.optionD,
        correctOption: correctOption ?? this.correctOption,
        explanation: explanation ?? this.explanation,
      );
}
