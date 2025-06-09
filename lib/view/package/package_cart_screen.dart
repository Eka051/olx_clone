import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

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
  bool _isLoading = false;

  Future<void> checkoutPackage() async {
    if (selectedIndex == null) return;

    final selected = packages[selectedIndex!];
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://your-api-url.com/api/payments/create'), // GANTI DENGAN API SEBENAR
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1, // GANTI SEMENTARA, nanti pakai dari login
          'packageName': selected['name'],
          'price': selected['price'],
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentUrl = data['paymentUrl'];

        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Tidak bisa membuka link pembayaran.');
        }
      } else {
        throw Exception('Gagal membuat pembayaran.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Terjadi Kesalahan'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

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
                    onPressed: _isLoading ? null : checkoutPackage,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Lanjut ke Pembayaran'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
