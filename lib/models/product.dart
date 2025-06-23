enum ProductStatus { active, sold, expired }

class Product {
  final int id;
  final String title;
  final String description;
  final int price;
  final int categoryId;
  final String categoryName;
  final List<String> images;
  final String cityName;
  final String provinceName;
  final String districtName;
  final DateTime createdAt;
  final ProductStatus status;
  final bool isFavorite;
  final String userId;
  final String sellerId;
  final String sellerName;
  final bool isActive;
  final int? adPackageId;

  Product({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    required this.categoryId,
    this.categoryName = '',
    this.images = const [],
    required this.cityName,
    required this.provinceName,
    required this.districtName,
    required this.createdAt,
    this.status = ProductStatus.active,
    this.isFavorite = false,
    required this.userId,
    required this.sellerId,
    required this.sellerName,
    required this.isActive,
    this.adPackageId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      cityName: json['cityName'] ?? '',
      provinceName: json['provinceName'] ?? '',
      districtName: json['districtName'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      status:
          (json['isSold'] ?? false) ? ProductStatus.sold : ProductStatus.active,
      isFavorite: json['isFavorite'] ?? false,
      userId: json['userId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      isActive: json['isActive'] ?? true,
      adPackageId: json['adPackageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'images': images,
      'cityName': cityName,
      'provinceName': provinceName,
      'districtName': districtName,
      'createdAt': createdAt.toIso8601String(),
      'isSold': status == ProductStatus.sold,
      'isFavorite': isFavorite,
      'userId': userId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isActive': isActive,
      'adPackageId': adPackageId,
    };
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';

  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get location {
    return [
      districtName,
      cityName,
      provinceName,
    ].where((s) => s.isNotEmpty).join(', ');
  }

  String get timePosted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
