import 'package:olx_clone/models/ad_feature.dart';

class AdPackage {
  final int id;
  final String name;
  final int price;
  final List<AdFeature> features;

  AdPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
  });

  String get description {
    if (features.isEmpty) return '';
    return features.map((f) => '${f.quantity} ${f.featureType} ${f.durationDays} hari').join(', ');
  }

  factory AdPackage.fromJson(Map<String, dynamic> json) {
    var featuresList = <AdFeature>[];
    if (json['features'] != null && json['features'] is List) {
      featuresList = (json['features'] as List<dynamic>)
          .map((featureJson) => AdFeature.fromJson(featureJson))
          .toList();
    }

    return AdPackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Package',
      price: json['price'] ?? 0,
      features: featuresList,
    );
  }
}
