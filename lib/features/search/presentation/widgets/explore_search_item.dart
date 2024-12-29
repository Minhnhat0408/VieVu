import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

class ExploreSearchItem extends StatelessWidget {
  final ExploreSearchResult? result;
  final bool isDetailed;

  const ExploreSearchItem({
    super.key,
    this.result,
    this.isDetailed = false,
  });

  Widget _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return const Icon(
          Icons.attractions,
          size: 40,
        );
      case 'locations':
        return const Icon(
          Icons.place,
          size: 40,
        );
      case 'travel_types':
        return const Icon(
          Icons.terrain_outlined,
          size: 40,
        );
      default:
        return const FaIcon(
          FontAwesomeIcons.locationArrow,
          size: 40,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('result: ${result?.title}');
    return InkWell(
      onTap: () {
        // Navigate to the detail page

        if (result?.type == 'event') {
          openDeepLink(result!.id);
        } else if (result?.type == 'attractions') {
          Navigator.pushNamed(context, '/attraction',
              arguments: int.parse(result!.id));
        } else if (result?.type == 'hotel' ||
            result?.type == 'restaurant' ||
            result?.type == 'shop') {
          // check if result.id contains http or https if not add https://vn.trip.com
          if (result!.id.contains('http') || result!.id.contains('https')) {
            openDeepLink(result!.id);
          } else {
            openDeepLink('https://vn.trip.com${result!.id}');
          }
        } else if (result?.type == 'locations') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocationDetailPage(
              locationId: int.parse(result!.id),
              locationName: result!.title,
            ),
          ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
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
              child: (result == null ||
                      (result!.type != 'attractions' &&
                          result!.type != 'event' &&
                          result!.type != 'hotel' &&
                          result!.type != 'restaurant' &&
                          result!.type != 'shop'))
                  ? _getIconForType(result == null ? 'nearby' : result!.type)
                  : CachedNetworkImage(
                      imageUrl: "${result!.cover}", // Use optimized size
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
                    if (isDetailed &&
                        (result!.type == 'attractions' ||
                            result!.type == 'hotel' ||
                            result!.type == 'restaurant' ||
                            result!.type == 'shop'))
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: result?.avgRating ?? 0,
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
                            '(${result?.ratingCount ?? 0})',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 10),
                          if (result?.hotScore != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.fire,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    result?.hotScore.toString() ?? '0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
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
      ),
    );
  }
}
