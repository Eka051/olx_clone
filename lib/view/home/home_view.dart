import 'package:flutter/material.dart';
import 'package:olx_clone/providers/auth_provider.dart';
import 'package:olx_clone/utils/theme.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderApp>(context);
    return Scaffold(
      backgroundColor: AppTheme.of(context).colors.secondary,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/LOGO-MEMBER-ASTRA.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text('Home Page'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/auth-option');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}