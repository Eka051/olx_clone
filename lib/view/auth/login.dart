import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/LOGO-MEMBER-ASTRA.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text('Login Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement login functionality here
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
