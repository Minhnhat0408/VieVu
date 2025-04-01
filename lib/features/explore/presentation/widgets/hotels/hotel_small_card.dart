import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/domain/entities/hotel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';

class HotelSmallCard extends StatefulWidget {
  final Hotel hotel;
  final bool slider;
  final int locationId;
  final String locationName;
  const HotelSmallCard({
    super.key,
    required this.hotel,
    this.slider = false,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<HotelSmallCard> createState() => _HotelSmallCardState();
}

class _HotelSmallCardState extends State<HotelSmallCard> {
  int changeSavedItemCount = 0;
  int? currentSavedTripCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.hotel.jumpUrl.contains('http') ||
            widget.hotel.jumpUrl.contains('https')) {
          openDeepLink(widget.hotel.jumpUrl);
        } else {
          final String url = 'https://vn.trip.com${widget.hotel.jumpUrl}';
          openDeepLink(url);
        }
      },
      child: Card(
          elevation: 0,
          color: widget.slider
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: widget.slider
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    // Image and Icon
                    const SizedBox(
                      width: 10,
                    ),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.hotel.cover, // Use optimized size
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            fadeInDuration: Duration
                                .zero, // Remove fade-in animation for faster display
                            filterQuality: FilterQuality.low,
                            useOldImageOnUrlChange:
                                true, // Avoid unnecessary reloads
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              onPressed: () {
                                final userId = (context
                                        .read<AppUserCubit>()
                                        .state as AppUserLoggedIn)
                                    .user
                                    .id;
                                context.read<TripBloc>().add(GetSavedToTrips(
                                      userId: userId,
                                      id: widget.hotel.id,
                                    ));
                                displayModal(context, SavedToTripModal(
                                  onTripsChanged: (List<Trip> selectedTrips,
                                      List<Trip> unselectedTrips) {
                                    setState(() {
                                      changeSavedItemCount =
                                          selectedTrips.length +
                                              unselectedTrips.length;
                                      currentSavedTripCount ??= 0;
                                      currentSavedTripCount =
                                          currentSavedTripCount! +
                                              selectedTrips.length -
                                              unselectedTrips.length;
                                    });

                                    for (var item in selectedTrips) {
                                      context
                                          .read<SavedServiceBloc>()
                                          .add(InsertSavedService(
                                            tripId: item.id,
                                            linkId: widget.hotel.id,
                                            cover: widget.hotel.cover,
                                            name: widget.hotel.name,
                                            locationName: widget.locationName,
                                            rating: widget.hotel.avgRating,
                                            ratingCount:
                                                widget.hotel.ratingCount,
                                            typeId: 4,
                                            externalLink: widget.hotel.jumpUrl,
                                            latitude: widget.hotel.latitude,
                                            hotelStar: widget.hotel.star,
                                            price: widget.hotel.price,
                                            longitude: widget.hotel.longitude,
                                          ));
                                    }

                                    for (var item in unselectedTrips) {
                                      context.read<SavedServiceBloc>().add(
                                          DeleteSavedService(
                                              linkId: widget.hotel.id,
                                              tripId: item.id));
                                    }
                                  },
                                ), null, false);
                              },
                              iconSize: 18,
                              style: IconButton.styleFrom(
                                padding:
                                    EdgeInsets.zero, // Remove extra padding
                                alignment: Alignment.center,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              icon: Icon(
                                currentSavedTripCount != null
                                    ? currentSavedTripCount! > 0
                                        ? Icons.favorite
                                        : Icons.favorite_border
                                    : widget.hotel.isSaved
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                color: currentSavedTripCount != null
                                    ? currentSavedTripCount! > 0
                                        ? Colors.redAccent
                                        : null
                                    : widget.hotel.isSaved
                                        ? Colors.redAccent
                                        : null,
                              ),
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
                              widget.hotel.name,
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
                                  rating: widget.hotel.avgRating,
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
                                  '(${widget.hotel.ratingCount})',
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
                                    rating: widget.hotel.star.toDouble(),
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
                                  child: Text(widget.hotel.positionDesc,
                                      maxLines: widget.slider ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      )),
                                ),
                              ],
                            ),
                            if (!widget.slider) const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!widget.slider) const SizedBox(height: 10),
                if (!widget.slider)
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
                          Text(widget.hotel.roomName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 4),
                          Text(widget.hotel.roomDesc,
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
                                  widget.hotel.adultCount,
                                  (index) => const Icon(
                                    FontAwesomeIcons.user,
                                    size: 14,
                                  ),
                                ),
                                ...List.generate(
                                  widget.hotel.childCount,
                                  (index) => const Icon(
                                    FontAwesomeIcons.child,
                                    size: 14,
                                  ),
                                ),
                              ]),

                              if (widget.hotel.price > 0)
                                Text(
                                  '${NumberFormat('#,###').format(widget.hotel.price)} VND',
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
