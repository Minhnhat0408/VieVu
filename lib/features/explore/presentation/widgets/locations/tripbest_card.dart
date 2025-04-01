import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/domain/entities/tripbest.dart';

class TripbestCard extends StatelessWidget {
  final TripBest tripBest;
  const TripbestCard({super.key, required this.tripBest});

  String convertBusinessType(String businessType) {
    switch (businessType) {
      case 'hotel':
        return 'Khách sạn';
      case 'restaurant':
        return 'Nhà hàng';
      case 'sight':
        return 'Địa điểm du lịch';
      case 'shop':
        return 'Mua sắm';
      case 'activity':
        return 'Hoạt động';
      case 'event':
        return 'Sự kiện';
      default:
        return 'Địa điểm du lịch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (tripBest.jumpUrl.contains('http') ||
            tripBest.jumpUrl.contains('https')) {
          openDeepLink(tripBest.jumpUrl);
        } else {
          final String url = 'https://vn.trip.com${tripBest.jumpUrl}';
          openDeepLink(url);
        }
      }, // Navigate to deep link
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          width: 230,
          height: 150,
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
                      imageUrl: tripBest.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 150,
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Top ${tripBest.totalCount} ${convertBusinessType(tripBest.businessType)}",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripBest.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
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
