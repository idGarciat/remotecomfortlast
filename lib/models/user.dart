class User {
  final int? id;
  final String name;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  User({this.id, required this.name, this.email, this.createdAt, this.updatedAt, this.deletedAt});

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    } catch (_) {}
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      deletedAt: _parseDate(json['deleted_at'] ?? json['deletedAt']),
    );
  }
}
