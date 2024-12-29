import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';

class RestaurantBigCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantBigCard({required this.restaurant, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (restaurant.jumpUrl.contains('http') ||
            restaurant.jumpUrl.contains('https')) {
          openDeepLink(restaurant.jumpUrl);
        } else {
          final String url = 'https://vn.trip.com${restaurant.jumpUrl}';
          openDeepLink(url);
        }
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          width: 220,
          child: Column(
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
                      imageUrl: "${restaurant.cover}?w=90&h=90",
                      fadeInDuration: const Duration(milliseconds: 200),
                      filterQuality: FilterQuality.low,
                      width: double.infinity,
                      height: 220,
                      useOldImageOnUrlChange: true,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      icon: const Icon(Icons.favorite_border),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      restaurant.name,
                      minFontSize: 14, // inimum font size to shrink to
                      maxLines: 2, // Allow up to 2 lines for wrapping
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if it exceeds maxLines
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Default starting font size
                      ),
                    ),

                    const SizedBox(height: 6),
                    // Rating
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: restaurant.avgRating,
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
                          '(${restaurant.ratingCount})',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Travel Types

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
                        //check if travelType is object or string
                        restaurant.cuisineName,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),

                    const SizedBox(height: 6),
                    // Price
                    Text(
                      'Từ: ${NumberFormat('#,###').format(restaurant.price)} VND',
                      style: TextStyle(
                        fontSize: 16,
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
    );
  }
}
