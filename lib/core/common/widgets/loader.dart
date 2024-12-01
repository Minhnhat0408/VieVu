import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.6),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
