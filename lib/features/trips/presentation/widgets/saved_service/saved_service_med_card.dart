import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';

class SavedServiceMedCard extends StatelessWidget {
  final SavedService service;
  final bool isSelected;
  const SavedServiceMedCard({
    super.key,
    required this.service,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceBright,
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceBright,
                width: 2.0,
              ),
            ),
            width: 90,
            height: 90,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: CachedNetworkImage(
              imageUrl: service.cover, // Use optimized size
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              fadeInDuration:
                  Duration.zero, // Remove fade-in animation for faster display
              filterQuality: FilterQuality.low,
              useOldImageOnUrlChange: true, // Avoid unnecessary reloads
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                    service.name,
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
                  if (service.typeId != 5 && service.typeId != 0)
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: service.rating,
                          itemSize: 20,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, _) => Icon(
                            Icons.favorite,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        Text(
                          '(${service.ratingCount ?? 0})',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      service.locationName,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
