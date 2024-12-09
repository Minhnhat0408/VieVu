import 'dart:ui';

import 'package:flutter/material.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Image.asset(
          'assets/images/intro1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
            child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5))),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Center(
              child: Image.asset('assets/images/logo2.png',
                  width: 250, height: 250),
            ),
          ),
        ),
      ],
    ));
  }
}
