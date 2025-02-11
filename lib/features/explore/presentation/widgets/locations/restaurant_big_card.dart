import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_location/trip_location_bloc.dart';

class RestaurantBigCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantBigCard({required this.restaurant, super.key});

  @override
  State<RestaurantBigCard> createState() => _RestaurantBigCardState();
}

class _RestaurantBigCardState extends State<RestaurantBigCard> {
  int changeSavedItemCount = 0;
  int? currentSavedTripCount;
  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is SavedToTripLoadedSuccess) {
          currentSavedTripCount =
              state.trips.where((trip) => trip.isSaved).length;
        }
      },
      child: InkWell(
        onTap: () {
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
                        imageUrl: "${widget.restaurant.cover}?w=90&h=90",
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
                        onPressed: () {
                          final userId = (context.read<AppUserCubit>().state
                                  as AppUserLoggedIn)
                              .user
                              .id;
                          context.read<TripBloc>().add(GetSavedToTrips(
                              userId: userId,
                              id: widget.restaurant.id,
                              type: 'service'));
                          displayModal(
                              context,
                              SavedToTripModal(
                                type: "service",
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
                                          linkId: widget.restaurant.id,
                                          cover: widget.restaurant.cover,
                                          name: widget.restaurant.name,
                                          locationName: (context
                                                      .read<LocationBloc>()
                                                      .state
                                                  as LocationDetailsLoadedSuccess)
                                              .location
                                              .name,
                                          rating: widget.restaurant.avgRating,
                                          ratingCount:
                                              widget.restaurant.ratingCount,
                                          price: widget.restaurant.price,
                                          tagInfoList: [
                                            widget.restaurant.cuisineName
                                          ],
                                          typeId: 1,
                                          latitude: widget.restaurant.latitude,
                                          longitude:
                                              widget.restaurant.longitude,
                                        ));

                                    context
                                        .read<TripLocationBloc>()
                                        .add(InsertTripLocation(
                                          locationId: (context
                                                      .read<LocationBloc>()
                                                      .state
                                                  as LocationDetailsLoadedSuccess)
                                              .location
                                              .id,
                                          tripId: item.id,
                                        ));
                                  }

                                  for (var item in unselectedTrips) {
                                    context.read<SavedServiceBloc>().add(
                                        DeleteSavedService(
                                            linkId: widget.restaurant.id,
                                            tripId: item.id));
                                  }
                                },
                              ),
                              null,
                              false);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.restaurant.name,
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
                            rating: widget.restaurant.avgRating,
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
                            '(${widget.restaurant.ratingCount})',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Travel Types

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
                          //check if travelType is object or string
                          widget.restaurant.cuisineName,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),

                      const SizedBox(height: 6),
                      // Price
                      if (widget.restaurant.price > 0)
                        Text(
                          'Từ: ${NumberFormat('#,###').format(widget.restaurant.price)} VND',
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
      ),
    );
  }
}
