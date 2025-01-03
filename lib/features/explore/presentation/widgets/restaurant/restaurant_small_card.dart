import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/utils/format_distance.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';

class RestaurantSmallCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantSmallCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the detail page
        Navigator.pushNamed(
          context,
          '/restaurant',
          arguments: restaurant.id,
        );
      },
      child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image and Icon
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: restaurant.cover, // Use optimized size
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        fadeInDuration: Duration
                            .zero, // Remove fade-in animation for faster display
                        filterQuality: FilterQuality.low,
                        useOldImageOnUrlChange:
                            true, // Avoid unnecessary reloads
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          onPressed: () {},
                          iconSize: 18,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove extra padding
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          icon: const Icon(Icons.favorite_border),
                        ),
                      ),
                    ),
                  ],
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
                          restaurant.name,
                          minFontSize: 14, // Minimum font size to shrink to
                          maxLines: 1, // Allow up to 2 lines for wrapping
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis if it exceeds maxLines
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Default starting font size
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            restaurant.cuisineName,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: restaurant.avgRating ?? 0,
                              itemSize: 20,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, _) => Icon(
                                Icons.favorite,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${restaurant.ratingCount})',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          child: Row(
                            children: [
                              if (restaurant.distance != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    Text(
                                      formatDistance(restaurant.distance!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              const SizedBox(width: 20),
                              Text(
                                '${NumberFormat('#,###').format(restaurant.price)} VND',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
