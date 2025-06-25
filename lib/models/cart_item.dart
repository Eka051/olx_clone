class CartItem {
  final String id;
  final int adPackageId;
  final int productId;
  final String adPackageName;
  final int price;
  final int quantity;

  CartItem({
    required this.id,
    required this.adPackageId,
    required this.productId,
    required this.adPackageName,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      adPackageId: json['adPackageId'] ?? 0,
      productId: json['productId'] ?? 0,
      adPackageName: json['adPackageName'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adPackageId': adPackageId,
    'productId': productId,
    'adPackageName': adPackageName,
    'quantity': quantity,
    'price': price,
  };

  CartItem copyWith({
    String? id,
    int? adPackageId,
    int? productId,
    String? adPackageName,
    int? quantity,
    int? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      adPackageId: adPackageId ?? this.adPackageId,
      productId: productId ?? this.productId,
      adPackageName: adPackageName ?? this.adPackageName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
