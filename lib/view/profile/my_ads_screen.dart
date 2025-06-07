import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/view/sell/sell_screen.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  Future<void> _deleteAd(String docId) async {
    await FirebaseFirestore.instance.collection('products').doc(docId).delete();
  }

  Future<void> _markAsSold(String docId) async {
    await FirebaseFirestore.instance.collection('products').doc(docId).update({
      'isSold': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseFirestore.instance.app.options.projectId;
    return Scaffold(
      appBar: AppBar(title: const Text('Iklan Saya')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada iklan yang kamu buat.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40),
                  title: Text(data['title'] ?? 'Tanpa Judul'),
                  subtitle: Text("Rp ${data['price'].toString()}", style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellScreen(
                              productId: docId,
                              initialData: data,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _deleteAd(docId);
                      } else if (value == 'sold') {
                        _markAsSold(docId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      const PopupMenuItem(value: 'sold', child: Text('Tandai Terjual')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
