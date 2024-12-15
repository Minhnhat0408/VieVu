import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/utils/format_distance.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';

class AttractionSmallCard extends StatelessWidget {
  final Attraction attraction;
  const AttractionSmallCard({
    super.key,
    required this.attraction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
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
                  child: Image.network(
                    attraction.cover,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction.name,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: attraction.avgRating ?? 0,
                        itemSize: 20,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, _) => Icon(
                          Icons.favorite,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                      Text(
                        '(${attraction.ratingCount})',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Text(
                        formatDistance(attraction.distance!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
