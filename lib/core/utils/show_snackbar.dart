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
        content: Text(message,
            style: const TextStyle(
              color: Colors.white,
            )),
        backgroundColor: state == SnackBarState.warning
            ? const Color.fromARGB(255, 209, 131, 15)
            : state == SnackBarState.error
                ? const Color.fromARGB(255, 172, 46, 37)
                : const Color.fromARGB(255, 49, 117, 51),
      ),
    );
}
