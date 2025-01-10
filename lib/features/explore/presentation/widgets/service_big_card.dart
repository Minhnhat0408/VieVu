import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';

class ServiceBigCard extends StatelessWidget {
  final Service service;
  final String type;

  const ServiceBigCard({required this.service, super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to service Details Page
        // Navigator.pushNamed(context, '/', arguments: service.id);
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
                      imageUrl: "${service.cover}?w=90&h=90",
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
                  if (service.hotScore != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.fire,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service.hotScore.toString(),
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
                          )),
                    ),
                  if (type == "Khách sạn" && service.star != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: RatingBarIndicator(
                          rating: service.star!,
                          itemSize: 24,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, _) => const Icon(Icons.star,
                              color: Color.fromARGB(255, 255, 234, 44)),
                        ),
                      ),
                    )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      service.name,
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
                          rating: service.score,
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
                          '(${service.aggreationCommentCount})',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Travel Types
                    if (service.tagInfoList != null)
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
                          service.tagInfoList![0]['tagName'] ?? '',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Price
                    if (service.avgPrice != null)
                      Text(
                        'Từ: ${NumberFormat('#,###').format(service.avgPrice)} VND',
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
