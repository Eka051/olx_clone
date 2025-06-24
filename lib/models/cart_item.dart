class CartItem {
  final String id;
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
    // Coba ambil totalPrice, price, atau hitung manual jika tidak ada
    int price = 0;
    if (json.containsKey('totalPrice')) {
      price = json['totalPrice'] ?? 0;
    } else if (json.containsKey('price')) {
      price = json['price'] ?? 0;
    } else if (json.containsKey('adPackagePrice')) {
      price = json['adPackagePrice'] ?? 0;
    }
    if (price == 0 && json['quantity'] != null && json['adPackagePrice'] != null) {
      price = (json['adPackagePrice'] ?? 0) * (json['quantity'] ?? 1);
    }
    return CartItem(
      id: json['id']?.toString() ?? '',
      adPackageId: json['adPackageId'] ?? 0,
      productId: json['productId'] ?? 0,
      adPackageName: json['adPackageName'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalPrice: price,
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
    String? id,
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
