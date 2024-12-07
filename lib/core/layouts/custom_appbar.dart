import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final Widget body; // Accepts a widget for the body
  final String? appBarTitle; // Optional title for the app bar
  final List<Widget>? actions; // Optional actions for the app bar

  const CustomAppbar({
    super.key,
    required this.body, // The body is required
    this.appBarTitle, // AppBar title is optional
    this.actions, // AppBar actions are optional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 36,
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back
                },
              )
            : null,
        title: appBarTitle != null ? Text(appBarTitle!) : null,
        actions: actions,
      ),
      body: body,
      
    );
  }
}
