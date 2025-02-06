import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final Widget body;
  final String? appBarTitle;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool extendBodyBehindAppBar;
  const CustomAppbar({
    super.key,
    required this.body,
    this.appBarTitle,
    this.actions,
    this.centerTitle = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,

        backgroundColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 32,
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back
                },
              )
            : null,
        title: appBarTitle != null ? Text(appBarTitle!) : null,
        actions: actions,
        centerTitle: centerTitle,
      ),
      body: body,
      
    );
  }
}
