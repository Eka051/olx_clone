import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/utils/theme.dart';

class PaymentPage extends StatefulWidget {
  final String productId;
  final String packageName;
  final String duration;
  final String price;

  const PaymentPage({
    super.key,
    required this.productId,
    required this.packageName,
    required this.duration,
    required this.price,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = 'E-Wallet';

  final List<String> paymentMethods = [
    'E-Wallet',
    'Virtual Account',
    'QRIS',
  ];

  Future<void> _onPay() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({'isPromoted': true});

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pembayaran Berhasil!'),
            content: const Text('Paket iklan Anda telah diaktifkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal update produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Paket Iklan'),
        backgroundColor: AppTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pembelian',
              style: AppTheme.of(context).textStyle.headlineMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paket: ${widget.packageName}'),
                  Text('Durasi: ${widget.duration}'),
                  Text('Harga: ${widget.price}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Metode Pembayaran',
              style: AppTheme.of(context).textStyle.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: paymentMethods.map((method) {
                return RadioListTile(
                  title: Text(method),
                  value: method,
                  groupValue: selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value.toString();
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
