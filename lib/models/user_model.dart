class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isGuest;
  final String? gender;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isGuest = false,
    this.gender,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isGuest,
    String? gender,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isGuest': isGuest,
        'gender': gender,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      // Handle cloud_firestore Timestamp dynamic check
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return UserModel(
      id: (json['id'] ?? json['uid'] ?? '') as String,
      name: (json['name'] ?? 'User') as String,
      email: (json['email'] ?? '') as String,
      isGuest: json['isGuest'] as bool? ?? false,
      gender: json['gender'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
