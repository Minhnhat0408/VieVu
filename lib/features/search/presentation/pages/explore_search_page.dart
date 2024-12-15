import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer for debouncing
  bool _isLoading = false; // Loading state
  List<Map<String, dynamic>> _results = []; // Store search results

  // Simulate search API call
  Future<List<Map<String, dynamic>>> _search(String keyword) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulated delay
    // Example response similar to your API
    return [
      {'type': 'travel_types', 'name': 'Núi', 'score': 2.06},
      {'type': 'attractions', 'name': 'núi Bà Đen', 'score': 0.086},
      {'type': 'attractions', 'name': 'Đồn Pháp', 'score': 0.082},
      {'type': 'locations', 'name': 'P. Núi Sam', 'score': 0.060},
    ]
        .where((item) => (item['name'] as String)
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();
  }

  // Handle text changes with debounce
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (keyword.isNotEmpty) {
        setState(() => _isLoading = true);
        final results = await _search(keyword);
        setState(() {
          _results = results;
          _isLoading = false;
        });
      } else {
        setState(() => _results = []);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return Icons.attractions;
      case 'locations':
        return Icons.place;
      case 'travel_types':
        return Icons.terrain;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 36,
                highlightColor: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        centerTitle: true,
        toolbarHeight: 90,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Thickness of the line
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer, // Line color
            height: 1.0, // Line thickness
          ),
        ),
        title: Hero(
          tag: 'exploreSearch',
          child: SearchBar(
            controller: _searchController,
            elevation: const WidgetStatePropertyAll(0),
            leading: const Icon(Icons.search),
            hintText: 'Tìm kiếm địa điểm du lịch...',
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(), // Show loading indicator
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No results found'))
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: Icon(_getIconForType(result['type'])),
                          title: Text(result['name']),
                          subtitle: Text(
                              'Type: ${result['type']} | Score: ${result['score']}'),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
