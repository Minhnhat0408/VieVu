import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';

class HotelSmallCard extends StatelessWidget {
  final Hotel hotel;
  final bool slider;
  const HotelSmallCard({
    super.key,
    required this.hotel,
    this.slider = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the detail page
        Navigator.pushNamed(
          context,
          '/hotel',
          arguments: hotel.id,
        );
      },
      child: Card(
          elevation: 0,
          color: slider
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: slider
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    // Image and Icon

                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: hotel.cover, // Use optimized size
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
                                padding:
                                    EdgeInsets.zero, // Remove extra padding
                                alignment: Alignment.center,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              icon: const Icon(Icons.favorite_border),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              hotel.name,
                              minFontSize: 14, // Minimum font size to shrink to
                              maxLines: 1, // Allow up to 2 lines for wrapping
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis if it exceeds maxLines
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // Default starting font size
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: hotel.avgRating,
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
                                Text(
                                  '(${hotel.ratingCount})',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: RatingBarIndicator(
                                    rating: hotel.star.toDouble(),
                                    itemSize: 16,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color:
                                            Color.fromARGB(255, 255, 232, 25)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                Expanded(
                                  child: Text(hotel.positionDesc,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!slider) const SizedBox(height: 10),
                if (!slider)
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hotel.roomName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 4),
                          Text(hotel.roomDesc,
                              style: const TextStyle(
                                fontSize: 12,
                              )),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // display multiple icons for adult and child count
                              Row(children: [
                                ...List.generate(
                                  hotel.adultCount,
                                  (index) => const Icon(
                                    FontAwesomeIcons.user,
                                    size: 14,
                                  ),
                                ),
                                ...List.generate(
                                  hotel.childCount,
                                  (index) => const Icon(
                                    FontAwesomeIcons.child,
                                    size: 14,
                                  ),
                                ),
                              ]),

                              if (hotel.price > 0)
                                Text(
                                  '${NumberFormat('#,###').format(hotel.price)} VND',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                // const SizedBox(height: 10),
              ],
            ),
          )),
    );
  }
}
