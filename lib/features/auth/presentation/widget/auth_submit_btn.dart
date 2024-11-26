import 'package:flutter/material.dart';

class AuthSubmitBtn extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;
  const AuthSubmitBtn({
    super.key,
    this.btnText = 'Submit',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        ),
        child: Text(btnText, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
