class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final int totalAds;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.createdAt,
    this.totalAds = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      totalAds: json['totalAds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'totalAds': totalAds,
    };
  }
}
