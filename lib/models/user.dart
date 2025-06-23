enum ProfileType {
  regular('Regular'),
  premium('Premium');

  const ProfileType(this.value);
  final String value;

  static ProfileType fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'premium':
        return ProfileType.premium;
      default:
        return ProfileType.regular;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final int totalAds;
  final ProfileType profileType;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.createdAt,
    this.totalAds = 0,
    this.profileType = ProfileType.regular,
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
      profileType: ProfileType.fromValue(json['profileType']),
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
      'profileType': profileType.value,
    };
  }

  bool get isPremium => profileType == ProfileType.premium;

  String get profileTypeString => profileType.value;

  // Create a copy with updated profile type
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? createdAt,
    int? totalAds,
    ProfileType? profileType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      totalAds: totalAds ?? this.totalAds,
      profileType: profileType ?? this.profileType,
    );
  }
}
