class Progress {
  final int id;
  final int userId;
  final int lessonId;
  final bool isCompleted;
  final double quizScore;
  final double completionPercent;
  final DateTime updatedAt;

  Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.isCompleted = false,
    this.quizScore = 0,
    this.completionPercent = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        lessonId: json['lesson_id'] as int,
        isCompleted: json['is_completed'] as bool? ?? false,
        quizScore: (json['quiz_score'] as num?)?.toDouble() ?? 0,
        completionPercent:
            (json['completion_percent'] as num?)?.toDouble() ?? 0,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'lesson_id': lessonId,
        'is_completed': isCompleted,
        'quiz_score': quizScore,
        'completion_percent': completionPercent,
        'updated_at': updatedAt.toIso8601String(),
      };

  Progress copyWith({
    int? id,
    int? userId,
    int? lessonId,
    bool? isCompleted,
    double? quizScore,
    double? completionPercent,
    DateTime? updatedAt,
  }) =>
      Progress(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        lessonId: lessonId ?? this.lessonId,
        isCompleted: isCompleted ?? this.isCompleted,
        quizScore: quizScore ?? this.quizScore,
        completionPercent: completionPercent ?? this.completionPercent,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
