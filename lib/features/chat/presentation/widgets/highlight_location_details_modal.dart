import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';

class HighlightLocationDetailsModal extends StatelessWidget {
  final Map<String, dynamic> locationDetails;
  const HighlightLocationDetailsModal({
    super.key,
    required this.locationDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locationDetails['cover'] != null)
              Stack(children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.onSurface,
                  child: CachedNetworkImage(
                    imageUrl: locationDetails['cover'],
                    width: double.infinity,
                    height: 250,
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
                    icon: Icon(
                      locationDetails['isSaved'] ?? false
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: locationDetails['isSaved'] ?? false
                          ? Colors.redAccent
                          : null,
                    ),
                  ),
                ),
              ]),
            const SizedBox(height: 10),
            if (locationDetails['locationName'] != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(
                  locationDetails['locationName'],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Text(
              locationDetails['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (locationDetails['avgRating'] != null)
              Row(
                children: [
                  RatingBarIndicator(
                    rating: locationDetails['avgRating'].toDouble(),
                    itemSize: 20,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, _) => Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${locationDetails['ratingCount']} đánh giá',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (locationDetails['type'] == 'attractions') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AttractionDetailPage(
                            attractionId: locationDetails['id'],
                          ),
                        ),
                      );
                    } else if (locationDetails['type'] == 'locations') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LocationDetailPage(
                            locationId: locationDetails['id'],
                            locationName: locationDetails['title'],
                          ),
                        ),
                      );
                    } else {
                      if (locationDetails['externalLink'] != null &&
                          (locationDetails['externalLink']!.contains('http') ||
                              locationDetails['externalLink']!
                                  .contains('https'))) {
                        openDeepLink(locationDetails['externalLink']!);
                      } else {
                        final String url =
                            'https://vn.trip.com${locationDetails['externalLink']}';
                        openDeepLink(url);
                      }
                    }
                  },
                  child: const Text('Xem chi tiết'),
                ),
              ],
            )
          ]),
    );
  }
}
