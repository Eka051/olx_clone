class CartItem {
  final int id;
  final int adPackageId;
  final int productId;
  final String adPackageName;
  final int quantity;
  final int totalPrice;

  CartItem({
    required this.id,
    required this.adPackageId,
    required this.productId,
    required this.adPackageName,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      adPackageId: json['adPackageId'] ?? 0,
      productId: json['productId'] ?? 0,
      adPackageName: json['adPackageName'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalPrice: json['totalPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adPackageId': adPackageId,
    'productId': productId,
    'adPackageName': adPackageName,
    'quantity': quantity,
    'totalPrice': totalPrice,
  };

  CartItem copyWith({
    int? id,
    int? adPackageId,
    int? productId,
    String? adPackageName,
    int? quantity,
    int? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      adPackageId: adPackageId ?? this.adPackageId,
      productId: productId ?? this.productId,
      adPackageName: adPackageName ?? this.adPackageName,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
