import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/constants/trip_filters.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/pages/trip_detail_page.dart';

class TripSmallItem extends StatelessWidget {
  final Trip trip;
  const TripSmallItem({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(
              tripId: trip.id,
              tripCover: trip.cover,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: "${trip.id} small item",
                  child: CachedNetworkImage(
                    imageUrl: trip.cover != null
                        ? "${trip.cover}"
                        : 'assets/images/trip_placeholder.webp',
                    errorWidget: (context, url, error) => Image.asset(
                     'assets/images/trip_placeholder.webp', // Fallback if loading fails
                      fit: BoxFit.cover,
                    ),
                    height: 200,
                    cacheManager: CacheManager(
                      Config(
                        trip.cover ?? "hello",
                        stalePeriod: const Duration(seconds: 10),
                      ),
                    ),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.status == 'planning'
                          ? const Color(0xFF90CAF9)
                          : trip.status == 'ongoing'
                              ? const Color(0xFF81C784)
                              : trip.status == 'completed'
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFE57373),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tripStatusList
                          .where((element) => element.value == trip.status)
                          .first
                          .label,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_outline,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.serviceCount} mục',
                          style: const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "${trip.name} ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.merriweather().fontFamily,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              trip.isPublished ? Icons.public : Icons.lock,
                              size: 18,
                              color:
                                  trip.isPublished ? Colors.green : Colors.red,
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (trip.locations.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          maxLines: 2,
                          softWrap: true,
                          trip.locations.length > 3
                              ? "${trip.locations.take(2).join(' - ')} và ${trip.locations.length - 2} nơi khác"
                              : trip.locations.join(' - '),
                        ),
                      ],
                    ),
                  if (trip.startDate != null && trip.endDate != null)
                    Row(
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.calendar_month,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(trip.startDate!)} - ${DateFormat('dd/MM/yyyy').format(trip.endDate!)}',
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
