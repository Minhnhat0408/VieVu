import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vievu/features/explore/domain/entities/location.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';

class LocationBigCard extends StatelessWidget {
  final Location location;
  const LocationBigCard({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to location detail page
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationDetailPage(
                locationId: location.id,
                locationName: location.name,
              ),
            ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: location.cover,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  location.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
