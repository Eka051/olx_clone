import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        _buildCategoryItem(context, 'assets/icons/electronics.png', 'Elektronik'),
        _buildCategoryItem(context, 'assets/icons/fashion.png', 'Fashion'),
        _buildCategoryItem(context, 'assets/icons/vehicles.png', 'Kendaraan'),
        _buildCategoryItem(context, 'assets/icons/home.png', 'Rumah'),
        _buildCategoryItem(context, 'assets/icons/sports.png', 'Olahraga'),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, String iconPath, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}