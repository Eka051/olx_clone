class MidtransConfig {
  final String clientKey;
  final bool isProduction;
  final String snapUrl;

  MidtransConfig({
    required this.clientKey,
    required this.isProduction,
    required this.snapUrl,
  });

  factory MidtransConfig.fromJson(Map<String, dynamic> json) {
    return MidtransConfig(
      clientKey: json['clientKey'] ?? '',
      isProduction: json['isProduction'] ?? false,
      snapUrl: json['snapUrl'] ?? '',
    );
  }
}