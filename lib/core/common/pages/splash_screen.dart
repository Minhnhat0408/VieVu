import 'package:flutter/material.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo2.png', width: 250, height: 250),
      ),
    );
  }
}
