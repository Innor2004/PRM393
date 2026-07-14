class Badge {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int requiredScore;

  Badge({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.requiredScore = 0,
  });


  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        iconUrl: json['iconUrl'] as String? ?? json['icon_url'] as String?,
        requiredScore: json['requiredScore'] as int? ?? json['required_score'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'requiredScore': requiredScore,
      };
}
