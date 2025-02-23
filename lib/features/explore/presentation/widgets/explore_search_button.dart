import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/search/presentation/pages/explore_search_page.dart';

class ExploreSearchButton extends StatelessWidget {
  final bool showNotification;
  const ExploreSearchButton({super.key, required this.showNotification});

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: showNotification ? 1.0 : 0.0,
            child: IconButton(
              onPressed: showNotification ? () {} : null,
              icon: const Icon(Icons.notifications_none),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
