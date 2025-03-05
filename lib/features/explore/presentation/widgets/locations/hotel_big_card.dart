import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelBigCard extends StatefulWidget {
  final Hotel hotel;

  const HotelBigCard({required this.hotel, super.key});

  @override
  State<HotelBigCard> createState() => _HotelBigCardState();
}

class _HotelBigCardState extends State<HotelBigCard> {
  int changeSavedItemCount = 0;
  int? currentSavedTripCount;
  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is SavedToTripLoadedSuccess) {
          currentSavedTripCount =
              state.trips.where((trip) => trip.isSaved).length;
        }
      },
      child: InkWell(
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
                        imageUrl: "${widget.hotel.cover}?w=90&h=90",
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
                                id: widget.hotel.id,
                              ));
                          displayModal(context, SavedToTripModal(
                            onTripsChanged: (List<Trip> selectedTrips,
                                List<Trip> unselectedTrips) {
                              setState(() {
                                changeSavedItemCount = selectedTrips.length +
                                    unselectedTrips.length;
                                currentSavedTripCount ??= 0;
                                currentSavedTripCount = currentSavedTripCount! +
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
                                      locationName: (context
                                                  .read<LocationBloc>()
                                                  .state
                                              as LocationDetailsLoadedSuccess)
                                          .location
                                          .name,
                                      externalLink: widget.hotel.jumpUrl,
                                      rating: widget.hotel.avgRating,
                                      ratingCount: widget.hotel.ratingCount,
                                      hotelStar: widget.hotel.star,
                                      price: widget.hotel.price,
                                      typeId: 4,
                                      latitude: widget.hotel.latitude,
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
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
                          rating: widget.hotel.star.toDouble(),
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
                        widget.hotel.name,
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
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
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
