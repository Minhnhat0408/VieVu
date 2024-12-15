import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

class ExploreSearchItem extends StatelessWidget {
  final ExploreSearchResult? result;

  const ExploreSearchItem({
    super.key,
    this.result,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return Icons.attractions;
      case 'locations':
        return Icons.place;
      case 'travel_types':
        return Icons.terrain_outlined;
      default:
        return Icons.mode_standby_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceBright,
                width: 2.0,
              ),
            ),
            width: 90,
            height: 90,
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            child: (result == null || result!.type != 'attractions')
                ? Icon(
                    _getIconForType(result == null ? 'nearby' : result!.type),
                    size: 40,
                  )
                : CachedNetworkImage(
                    imageUrl:
                        "${result!.cover}?w=90&h=90", // Use optimized size
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    fadeInDuration: Duration
                        .zero, // Remove fade-in animation for faster display
                    filterQuality: FilterQuality.low,
                    useOldImageOnUrlChange: true, // Avoid unnecessary reloads
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            // Ensure this widget allows text to take available space
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    result == null ? 'Lân cận' : result!.title,
                    minFontSize: 14, // Minimum font size to shrink to
                    maxLines: 2, // Allow up to 2 lines for wrapping
                    overflow: TextOverflow
                        .ellipsis, // Add ellipsis if it exceeds maxLines
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Default starting font size
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (result != null && result!.address != null)
                    Text(
                      result!.address!,
                      softWrap: true, // Wrap the address to the next line
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
