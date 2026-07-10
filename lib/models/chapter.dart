class Chapter {
  final int id;
  final int bookId;
  final String title;
  final String? description;
  final int orderIndex;

  Chapter({
    required this.id,
    required this.bookId,
    required this.title,
    this.description,
    required this.orderIndex,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as int,
        bookId: json['book_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        orderIndex: json['order_index'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'title': title,
        'description': description,
        'order_index': orderIndex,
      };

  Chapter copyWith({
    int? id,
    int? bookId,
    String? title,
    String? description,
    int? orderIndex,
  }) =>
      Chapter(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        title: title ?? this.title,
        description: description ?? this.description,
        orderIndex: orderIndex ?? this.orderIndex,
      );
}
