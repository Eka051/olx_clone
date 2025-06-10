import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:olx_clone/providers/auth_provider.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List<dynamic> history = [];
  bool isLoading = true;

  Future<void> fetchHistory() async {
    final userProvider = Provider.of<AuthProviderApp>(context, listen: false);
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/api/payments/history?userId=$userId'), // GANTI
      );

      if (response.statusCode == 200) {
        setState(() {
          history = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat riwayat');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembelian Paket')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text('Belum ada pembelian paket.'))
              : ListView.builder(
                  itemCount: history.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(item['packageName'] ?? 'Paket'),
                        subtitle: Text('Harga: Rp ${item['price']}'),
                        trailing: Text(
                          item['status'] == 'PAID' ? 'Berhasil' : 'Pending',
                          style: TextStyle(
                            color: item['status'] == 'PAID'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
