import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/search/presentation/pages/explore_search_page.dart';

class ExploreSearch extends StatefulWidget {
  final bool showNotification;
  const ExploreSearch({super.key, required this.showNotification});

  @override
  State<ExploreSearch> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearch> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(ExploreSearchPage.route());
      },
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tìm kiếm địa điểm du lịch...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: widget.showNotification ? 1.0 : 0.0,
            child: IconButton(
              onPressed: widget.showNotification ? () {} : null,
              icon: const Icon(Icons.notifications_none),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
