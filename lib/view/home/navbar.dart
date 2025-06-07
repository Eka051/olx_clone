import 'package:flutter/material.dart';
import 'package:olx_clone/view/home/home_page.dart';
import 'package:olx_clone/view/package/package_cart_screen.dart';
import 'package:olx_clone/view/profile/profile_page.dart';
import 'package:olx_clone/view/sell/sell_screen.dart';
import 'package:olx_clone/view/notification/notification_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40), // space for FAB
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => _onItemTapped(3),
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
