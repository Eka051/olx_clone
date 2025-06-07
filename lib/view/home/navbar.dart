import 'package:flutter/material.dart';
import 'package:olx_clone/view/home/home_page.dart';
import 'package:olx_clone/view/package/package_cart_screen.dart';
import 'package:olx_clone/view/profile/profile_page.dart';
import 'package:olx_clone/view/sell/sell_screen.dart';
import 'package:olx_clone/view/notification/notification_page.dart';
import 'package:olx_clone/utils/theme.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PackageCartScreen(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSellButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellScreen()),
    );
  }

  Widget _buildBottomAppBarItem({
    required IconData iconData,
    required String label,
    required int index,
    bool isSelected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: isSelected ? AppTheme.of(context).primary : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppTheme.of(context).primary : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            _buildBottomAppBarItem(
              iconData: Icons.home,
              label: 'Beranda',
              index: 0,
              isSelected: _currentIndex == 0,
            ),
            _buildBottomAppBarItem(
              iconData: Icons.shopping_bag,
              label: 'Paket',
              index: 1,
              isSelected: _currentIndex == 1,
            ),
            const SizedBox(width: 40),
            _buildBottomAppBarItem(
              iconData: Icons.notifications,
              label: 'Notifikasi',
              index: 2,
              isSelected: _currentIndex == 2,
            ),
            _buildBottomAppBarItem(
              iconData: Icons.person,
              label: 'Profil',
              index: 3,
              isSelected: _currentIndex == 3,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onSellButtonPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
