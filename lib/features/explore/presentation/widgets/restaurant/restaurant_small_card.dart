import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/format_distance.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/domain/entities/restaurant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';

class RestaurantSmallCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool slider;
  final int locationId;
  final String locationName;
  const RestaurantSmallCard({
    super.key,
    required this.restaurant,
    this.slider = false,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<RestaurantSmallCard> createState() => _RestaurantSmallCardState();
}

class _RestaurantSmallCardState extends State<RestaurantSmallCard> {
  int? currentSavedTripCount;
  bool _showFull = false;
  int changeSavedItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is SavedToTripLoadedSuccess) {
          currentSavedTripCount =
              state.trips.where((trip) => trip.isSaved).length;
        }
      },
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigate to the detail page
              if (widget.restaurant.jumpUrl.contains('http') ||
                  widget.restaurant.jumpUrl.contains('https')) {
                openDeepLink(widget.restaurant.jumpUrl);
              } else {
                final String url =
                    'https://vn.trip.com${widget.restaurant.jumpUrl}';
                openDeepLink(url);
              }
            },
            child: Card(
                elevation: 0,
                color: widget.slider
                    ? Theme.of(context).colorScheme.surfaceContainerLowest
                    : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 10),
                  child: Column(
                    children: [
                      Row(
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
                                  imageUrl: widget
                                      .restaurant.cover, // Use optimized size
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
                                      context
                                          .read<TripBloc>()
                                          .add(GetSavedToTrips(
                                            userId: userId,
                                            id: widget.restaurant.id,
                                          ));
                                      displayModal(context, SavedToTripModal(
                                        onTripsChanged:
                                            (List<Trip> selectedTrips,
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
                                                  linkId: widget.restaurant.id,
                                                  cover:
                                                      widget.restaurant.cover,
                                                  name: widget.restaurant.name,
                                                  locationName:
                                                      widget.locationName,
                                                  rating: widget
                                                      .restaurant.avgRating,
                                                  ratingCount: widget
                                                      .restaurant.ratingCount,
                                                  typeId: 1,
                                                  price:
                                                      widget.restaurant.price,
                                                  tagInfoList: [
                                                    widget
                                                        .restaurant.cuisineName
                                                  ],
                                                  externalLink:
                                                      widget.restaurant.jumpUrl,
                                                  latitude: widget
                                                      .restaurant.latitude,
                                                  longitude: widget
                                                      .restaurant.longitude,
                                                ));
                                          }

                                          for (var item in unselectedTrips) {
                                            context
                                                .read<SavedServiceBloc>()
                                                .add(DeleteSavedService(
                                                    linkId:
                                                        widget.restaurant.id,
                                                    tripId: item.id));
                                          }
                                        },
                                      ), null, false);
                                    },
                                    iconSize: 18,
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets
                                          .zero, // Remove extra padding
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
                                          : widget.restaurant.isSaved
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                      color: currentSavedTripCount != null
                                          ? currentSavedTripCount! > 0
                                              ? Colors.redAccent
                                              : null
                                          : widget.restaurant.isSaved
                                              ? Colors.redAccent
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            // Ensure this widget allows text to take available space
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    widget.restaurant.name,
                                    minFontSize:
                                        14, // Minimum font size to shrink to
                                    maxLines:
                                        1, // Allow up to 2 lines for wrapping
                                    overflow: TextOverflow
                                        .ellipsis, // Add ellipsis if it exceeds maxLines
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          16, // Default starting font size
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    child: Text(
                                      widget.restaurant.cuisineName,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: widget.restaurant.avgRating,
                                        itemSize: 18,
                                        direction: Axis.horizontal,
                                        itemCount: 5,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.favorite,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${widget.restaurant.ratingCount})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        if (widget.restaurant.distance != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                              Text(
                                                formatDistance(widget
                                                    .restaurant.distance!),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        const SizedBox(width: 20),
                                        Text(
                                          '${NumberFormat('#,###').format(widget.restaurant.price)} VND',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.restaurant.userNickname != null &&
                          !widget.slider)
                        const SizedBox(height: 16),
                      if (widget.restaurant.userNickname != null &&
                          !widget.slider)
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: NetworkImage(
                                          widget.restaurant.userAvatar!),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.restaurant.userNickname!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _showFull
                                            ? widget.restaurant.userContent
                                            : widget.restaurant.userContent!
                                                        .length >
                                                    100
                                                ? '${widget.restaurant.userContent!.substring(0, 100)}...'
                                                : widget.restaurant
                                                    .userContent, // Adjust length
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (!_showFull &&
                                          widget.restaurant.userContent!
                                                  .length >
                                              100)
                                        TextSpan(
                                          text: ' Xem thêm',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                _showFull = true;
                                              });
                                            },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      if (widget.restaurant.userNickname != null &&
                          !widget.slider)
                        const SizedBox(height: 16),
                    ],
                  ),
                )),
          ),
          if (widget.restaurant.userNickname != null && !widget.slider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
