import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vn_travel_companion/core/constants/transport_options.dart';
import 'package:vn_travel_companion/core/constants/trip_filters.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';

class TripPostItem extends StatefulWidget {
  final Trip trip;
  const TripPostItem({
    super.key,
    required this.trip,
  });

  @override
  State<TripPostItem> createState() => _TripPostItemState();
}

class _TripPostItemState extends State<TripPostItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(
              tripId: widget.trip.id,
              tripCover: widget.trip.cover,
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
                CachedNetworkImage(
                  imageUrl: widget.trip.cover ?? '',
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
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
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.trip.status == 'completed' && widget.trip.rating > 0)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trip.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Row(
                    children: [
                      ...widget.trip.transports!.map((transport) {
                        final option = transportOptions.firstWhere(
                          (element) => element.value == transport,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Tooltip(
                            message: option.label, // Show label in tooltip
                            child: option.badge,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                if (widget.trip.user != null)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.trip.user!.avatarUrl ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 20,
                            backgroundImage: imageProvider,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.trip.user!.lastName} ${widget.trip.user!.firstName}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 14),
                            ),
                            Text(
                              timeago.format(widget.trip.publishedTime!,
                                  locale: 'vi'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 215, 215, 215),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],
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
                      color: widget.trip.status == 'planning'
                          ? const Color(0xFF90CAF9)
                          : widget.trip.status == 'ongoing'
                              ? const Color(0xFF81C784)
                              : widget.trip.status == 'completed'
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFE57373),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tripStatusList
                          .where(
                              (element) => element.value == widget.trip.status)
                          .first
                          .label,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.trip.locations.join(' - '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                        "${DateFormat('dd/MM/yyyy').format(widget.trip.startDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.trip.endDate!)}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: Icon(
                          Icons.person,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.trip.maxMember!} thành viên tối đa',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: Icon(
                          Icons.favorite_outline,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.trip.serviceCount} mục đã lưu',
                      ),
                    ],
                  ),
                ],
              ),

              // const SizedBox(
              //   width: 10,
              // ),
              // Column(
              //   children: [
              //     IconButton(
              //         style: IconButton.styleFrom(
              //           backgroundColor:
              //               Theme.of(context).colorScheme.primaryContainer,
              //         ),
              //         onPressed: () {},
              //         icon: const Icon(Icons.bookmark)),
              //     IconButton(
              //         onPressed: () {
              //           Navigator.of(context).push(
              //             MaterialPageRoute(
              //               builder: (context) => TripDetailPage(
              //                 tripId: widget.trip.id,
              //                 tripCover: widget.trip.cover,
              //               ),
              //             ),
              //           );
              //         },
              //         style: IconButton.styleFrom(
              //           backgroundColor:
              //               Theme.of(context).colorScheme.tertiaryContainer,
              //         ),
              //         icon: const Icon(Icons.travel_explore)),
              //   ],
              // )
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
