import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class TripSmallItem extends StatelessWidget {
  final Trip trip;
  const TripSmallItem({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return TripDetailPage(trip: trip);
        }));
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
                  tag: trip.id,
                  child: CachedNetworkImage(
                    imageUrl: trip.cover ?? '',
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/trip_placeholder.avif', // Fallback if loading fails
                      fit: BoxFit.cover,
                    ),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Lên kế hoạch',
                      style: TextStyle(
                        color: Colors.white,
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
                      text: trip.name,
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
                          trip.locations.length > 3
                              ? "${trip.locations.take(2).join(' - ')} và ${trip.locations.length - 2} nơi khác"
                              : trip.locations.join(' - '),
                        ),
                      ],
                    ),
                  if (trip.startDate != null && trip.endDate != null)
                    const Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.calendar_month,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '10/10/2021 - 20/10/2021',
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
