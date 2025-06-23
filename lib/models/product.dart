enum ProductStatus { active, sold, inactive, pending }

class Product {
  final String id;
  final String title;
  final String description;
  final int price;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final String location;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductStatus status;
  final bool isFavorite;
  final DateTime postedDate;

  Product({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    this.categoryId = '',
    this.categoryName = '',
    this.images = const [],
    required this.location,
    this.sellerId = '',
    this.sellerName = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = ProductStatus.active,
    this.isFavorite = false,
    required this.postedDate,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Legacy constructor for backward compatibility
  Product.legacy({
    required this.id,
    required this.title,
    required String priceString,
    required this.location,
    required String imageUrl,
    this.isFavorite = false,
    required this.postedDate,
  }) : description = '',
       price = int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
       categoryId = '',
       categoryName = '',
       images = [imageUrl],
       sellerId = '',
       sellerName = '',
       createdAt = DateTime.now(),
       updatedAt = DateTime.now(),
       status = ProductStatus.active;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'active'),
        orElse: () => ProductStatus.active,
      ),
      isFavorite: json['isFavorite'] ?? false,
      postedDate: DateTime.parse(
        json['postedDate'] ?? DateTime.now().toIso8601String(),
      ),
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
      'location': location,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'isFavorite': isFavorite,
      'postedDate': postedDate.toIso8601String(),
    };
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';
  // Format price dengan proper formatting
  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Get time since posted
  String get timePosted {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

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

  // Sample products for demo
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: '1',
        title: 'iPhone 14 Pro Max 256GB Space Black',
        price: 18500000,
        location: 'Jakarta Selatan',
        images: ['assets/images/image-ads.jpg'],
        postedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Product(
        id: '2',
        title: 'Honda Civic Type R 2023 Merah',
        price: 850000000,
        location: 'Bandung',
        images: ['assets/images/booking.jpg'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '3',
        title: 'Laptop Gaming ASUS ROG Strix',
        price: 25000000,
        location: 'Surabaya',
        images: ['assets/images/KV-SUPER-DEALS.png'],
        postedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Product(
        id: '4',
        title: 'Yamaha NMAX 2024 Connected',
        price: 32000000,
        location: 'Yogyakarta',
        images: ['assets/images/PREMIUM-OLX.jpg'],
        postedDate: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Product(
        id: '5',
        title: 'Samsung Galaxy S24 Ultra 512GB',
        price: 22000000,
        location: 'Semarang',
        images: ['assets/images/image-ads.jpg'],
        postedDate: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Product(
        id: '6',
        title: 'Toyota Fortuner VRZ 2023',
        price: 580000000,
        location: 'Malang',
        images: ['assets/images/booking.jpg'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
