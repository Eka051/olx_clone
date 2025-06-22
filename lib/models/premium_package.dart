class PremiumPackage {
  final int id;
  final String description;
  final int price;
  final int durationDays;
  final bool isActive;

  PremiumPackage({
    required this.id,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  factory PremiumPackage.fromJson(Map<String, dynamic> json) {
    return PremiumPackage(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'isActive': isActive,
    };
  }

  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  int get originalPrice {
    return (price * 2).toInt();
  }

  String get formattedOriginalPrice {
    return 'Rp ${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get durationText {
    if (durationDays >= 365) {
      int years = (durationDays / 365).floor();
      return '$years tahun';
    } else if (durationDays >= 30) {
      int months = (durationDays / 30).floor();
      return '$months bulan';
    } else {
      return '$durationDays hari';
    }
  }

  bool get isRecommended {
    return durationDays >= 365;
  }
}
