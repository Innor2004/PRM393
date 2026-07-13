class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Student',
    this.avatarUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'Student',
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.parse(
        (json['createdAt'] ?? json['created_at']) as String,
      )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}