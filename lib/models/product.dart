class Product {
  final String id;
  final String title;
  final String price;
  final String location;
  final String imageUrl;
  final bool isFavorite;
  final DateTime postedDate;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    this.isFavorite = false,
    required this.postedDate,
  });

  // Format price dengan proper formatting
  String get formattedPrice {
    return price.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
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
        price: 'Rp 18.500.000',
        location: 'Jakarta Selatan',
        imageUrl: 'assets/images/image-ads.jpg',
        postedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Product(
        id: '2',
        title: 'Honda Civic Type R 2023 Merah',
        price: 'Rp 850.000.000',
        location: 'Bandung',
        imageUrl: 'assets/images/booking.jpg',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '3',
        title: 'Laptop Gaming ASUS ROG Strix',
        price: 'Rp 25.000.000',
        location: 'Surabaya',
        imageUrl: 'assets/images/KV-SUPER-DEALS.png',
        postedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Product(
        id: '4',
        title: 'Yamaha NMAX 2024 Connected',
        price: 'Rp 32.000.000',
        location: 'Yogyakarta',
        imageUrl: 'assets/images/PREMIUM-OLX.jpg',
        postedDate: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Product(
        id: '5',
        title: 'Samsung Galaxy S24 Ultra 512GB',
        price: 'Rp 22.000.000',
        location: 'Semarang',
        imageUrl: 'assets/images/image-ads.jpg',
        postedDate: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Product(
        id: '6',
        title: 'Toyota Fortuner VRZ 2023',
        price: 'Rp 580.000.000',
        location: 'Malang',
        imageUrl: 'assets/images/booking.jpg',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
