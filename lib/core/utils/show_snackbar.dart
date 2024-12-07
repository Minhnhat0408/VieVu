import 'package:flutter/material.dart';

class SnackBarState {
  static const String success = 'success';
  static const String error = 'error';
  static const String warning = 'warning';
}

void showSnackbar(BuildContext context, String message, [String? state]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        behavior: SnackBarBehavior.floating,
        backgroundColor: state == SnackBarState.warning
            ? const Color.fromARGB(255, 209, 131, 15)
            : state == SnackBarState.error
                ? const Color.fromARGB(255, 172, 46, 37)
                : Theme.of(context).colorScheme.primary,
      ),
    );
}
