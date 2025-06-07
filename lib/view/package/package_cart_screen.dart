import 'package:flutter/material.dart';

class PackageCartScreen extends StatefulWidget {
  const PackageCartScreen({super.key});

  @override
  State<PackageCartScreen> createState() => _PackageCartScreenState();
}

class _PackageCartScreenState extends State<PackageCartScreen> {
  final List<Map<String, dynamic>> packages = [
    {
      'name': 'Top Ads',
      'description': 'Iklan ditampilkan di atas selama 7 hari.',
      'price': 25000,
    },
    {
      'name': 'Bump Up',
      'description': 'Iklan muncul ulang di urutan teratas.',
      'price': 15000,
    },
    {
      'name': 'Premium Ads',
      'description': 'Iklan lebih mencolok dan tampil di halaman utama.',
      'price': 40000,
    },
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final selectedPackage =
        selectedIndex != null ? packages[selectedIndex!] : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Paket Iklan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
                final isSelected = selectedIndex == index;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(pkg['name']),
                    subtitle: Text(pkg['description']),
                    trailing: Text('Rp ${pkg['price']}'),
                    leading: Radio<int>(
                      value: index,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedPackage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total Harga: Rp ${selectedPackage['price']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke pembayaran
                    },
                    child: const Text('Lanjut ke Pembayaran'),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
