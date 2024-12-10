import 'package:flutter/material.dart';

class ExploreSearchPage extends StatefulWidget {
  static route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ExploreSearchPage(),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Return a FadeTransition for the page content change
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      }, // Set duration
    );
  }

  const ExploreSearchPage({super.key});

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 36,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: const EdgeInsets.only(
                    top: 4, bottom: 4, left: 10, right: 4),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back
                },
              )
            : null,
        centerTitle: true,
        title: const Hero(
          tag: 'exploreSearch',
          child: SearchBar(
            constraints: BoxConstraints(
              maxHeight: 100,
              minHeight: 50,
            ),
            autoFocus: true,
            leading: Icon(Icons.search),
            padding: WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16)),
            hintText: 'Tìm kiếm địa điểm du lịch...',
          ),
        ),
      ),
      body: const SizedBox(),
    );
  }
}
