class AdFeature {
  final String featureType;
  final int quantity;
  final int durationDays;

  AdFeature({
    required this.featureType,
    required this.quantity,
    required this.durationDays,
  });

  factory AdFeature.fromJson(Map<String, dynamic> json) {
    return AdFeature(
      featureType: json['featureType'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
    );
  }
}