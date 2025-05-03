import 'package:flutter/material.dart';
import 'package:olx_clone/view/login.dart';

void main() {
  runApp(const OlxClone());
}

class OlxClone extends StatelessWidget {
  const OlxClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginView(),
    );
  }
}
