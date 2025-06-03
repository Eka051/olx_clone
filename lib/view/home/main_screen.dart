import 'package:flutter/material.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:olx_clone/view/sell/sell_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
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

  Widget _buildBottomAppBarItem(
      {required IconData iconData,
      required String label,
      required int index,
      bool isSelected = false}) {
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                color: isSelected ? AppTheme.of(context).colors.primary : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.of(context).colors.primary : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSellButtonPressed,
        shape: const CircleBorder(),
        elevation: 2.0,
        child: const Icon(Icons.camera_alt_outlined, size: 28),
      ),
    );
  }
}