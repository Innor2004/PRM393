class Book {
  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        coverImage: json['cover_image'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cover_image': coverImage,
        'created_at': createdAt.toIso8601String(),
      };
}
