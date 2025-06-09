import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olx_clone/view/product/product_detail_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Elektronik', 'Kendaraan', 'Properti'];

  final List<Map<String, dynamic>> _products = const [
    {
      'judul': 'Laptop Lenovo Thinkpad',
      'harga': 2500000,
      'lokasi': 'Surabaya',
      'kategori': 'Elektronik',
      'gambarUrl': 'https://picsum.photos/200/300?random=1',
      'deskripsi': 'Laptop bekas mulus fullset'
    },
    {
      'judul': 'iPhone 12 Pro',
      'harga': 7500000,
      'lokasi': 'Jakarta',
      'kategori': 'Elektronik',
      'gambarUrl': 'https://picsum.photos/200/300?random=2',
      'deskripsi': 'iPhone 12 Pro 128GB, fullset, batre 89%'
    },
    {
      'judul': 'Motor Beat 2020',
      'harga': 11000000,
      'lokasi': 'Malang',
      'kategori': 'Kendaraan',
      'gambarUrl': 'https://picsum.photos/200/300?random=3',
      'deskripsi': 'Motor Beat 2020, surat lengkap, pajak panjang'
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((p) {
      final matchQuery = p['judul'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' || p['kategori'] == _selectedCategory;
      return matchQuery && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OLX Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) => setState(() => _selectedCategory = value!),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product['gambarUrl'],
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['judul'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp ${NumberFormat('#,###').format(product['harga'])}",
                                  style: const TextStyle(color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['lokasi'],
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}