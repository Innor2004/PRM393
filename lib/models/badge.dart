class Badge {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        iconUrl: json['iconUrl'] as String? ?? json['icon_url'] as String?,
        earnedAt: json['earnedAt'] != null
            ? DateTime.parse(json['earnedAt'] as String)
            : null,
      );
}
