import 'package:flutter/material.dart';

class HalamanNew extends StatelessWidget {
  const HalamanNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman baru ditambahkan')),
      body: Center(
        child: Text('Ini adalah halaman baru yang berhasil ditambahkan'),
      ),
    );
  }
}
