class Lesson {
  final int id;
  final int chapterId;
  final String title;
  final int orderIndex;
  final int estimatedMinutes;
  final int difficultyStars;
  final String? contentBody;

  Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.orderIndex,
    required this.estimatedMinutes,
    this.difficultyStars = 1,
    this.contentBody,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      chapterId: json['chapterId'] as int? ?? json['chapter_id'] as int,
      title: json['title'] as String,
      orderIndex: json['orderIndex'] as int? ?? json['order_index'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? json['estimated_minutes'] as int? ?? 15,
      difficultyStars: json['difficultyStars'] as int? ?? json['difficulty_stars'] as int? ?? 1,
      contentBody: json['contentBody'] as String? ?? json['content_body'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'title': title,
        'orderIndex': orderIndex,
        'estimatedMinutes': estimatedMinutes,
        'difficultyStars': difficultyStars,
        'contentBody': contentBody,
      };

  Lesson copyWith({
    int? id,
    int? chapterId,
    String? title,
    int? orderIndex,
    int? estimatedMinutes,
    int? difficultyStars,
    String? contentBody,
  }) =>
      Lesson(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        title: title ?? this.title,
        orderIndex: orderIndex ?? this.orderIndex,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        contentBody: contentBody ?? this.contentBody,
      );
}
