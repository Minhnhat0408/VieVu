import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const SignUpPage());
  }

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
