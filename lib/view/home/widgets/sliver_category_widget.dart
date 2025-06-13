import 'package:flutter/material.dart';

class SliverCategoryWidget extends StatelessWidget {
  const SliverCategoryWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _buildCategoryItem(
              context,
              'assets/icons/GIFT-1.png',
              'Barang Gratis',
            ),
            _buildCategoryItem(context, 'assets/icons/CAR.png', 'Mobil'),
            _buildCategoryItem(
              context,
              'assets/icons/PROPERTI.png',
              'Properti',
            ),
            _buildCategoryItem(context, 'assets/icons/MOTOR.png', 'Motor'),
            _buildCategoryItem(
              context,
              'assets/icons/LOKER.png',
              'Jasa & Lowongan',
            ),
            _buildCategoryItem(
              context,
              'assets/icons/HOBI.png',
              'Hobi & Olahraga',
            ),
            _buildCategoryItem(
              context,
              'assets/icons/RUMAH-TANGGA.png',
              'Rumah Tangga',
            ),
            _buildCategoryItem(
              context,
              'assets/icons/PRIBADI.png',
              'Keperluan Pribadi',
            ),
            _buildCategoryItem(
              context,
              'assets/icons/BAYI.png',
              'Perlengkapan Bayi',
            ),
            _buildCategoryItem(
              context,
              'assets/icons/KANTOR.png',
              'Kantor & Industri',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String iconPath,
    String title,
  ) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              iconPath,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.category,
                  color: Colors.grey[400],
                  size: 20,
                );
              },
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
