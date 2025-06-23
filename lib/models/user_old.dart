enum ProfileType {
  regular(0),
  premium(1);

  const ProfileType(this.value);
  final int value;

  static ProfileType fromValue(int value) {
    switch (value) {
      case 1:
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
    ProfileType? profileType,
  }) : profileType = profileType ?? ProfileType.regular;
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
      profileType: ProfileType.fromValue(json['profileType'] ?? 0),
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
}
