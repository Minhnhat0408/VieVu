import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/format_distance.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class AttractionSmallCard extends StatefulWidget {
  final Attraction attraction;
  const AttractionSmallCard({
    super.key,
    required this.attraction,
  });

  @override
  State<AttractionSmallCard> createState() => _AttractionSmallCardState();
}

class _AttractionSmallCardState extends State<AttractionSmallCard> {
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
          // Navigate to the detail page
          Navigator.pushNamed(
            context,
            '/attraction',
            arguments: widget.attraction.id,
          );
        },
        child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Row(
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
                        imageUrl: widget.attraction.cover, // Use optimized size
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
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          onPressed: () {
                            final userId = (context.read<AppUserCubit>().state
                                    as AppUserLoggedIn)
                                .user
                                .id;
                            context.read<TripBloc>().add(GetSavedToTrips(
                                  userId: userId,
                                  id: widget.attraction.id,
                                ));
                            displayModal(context, SavedToTripModal(
                              onTripsChanged: (List<Trip> selectedTrips,
                                  List<Trip> unselectedTrips) {
                                setState(() {
                                  changeSavedItemCount = selectedTrips.length +
                                      unselectedTrips.length;
                                  currentSavedTripCount ??= 0;
                                  currentSavedTripCount =
                                      currentSavedTripCount! +
                                          selectedTrips.length -
                                          unselectedTrips.length;
                                });
                                if (selectedTrips.isNotEmpty) {
                                  final currentPref = (context
                                          .read<PreferencesBloc>()
                                          .state as PreferencesLoadedSuccess)
                                      .preference;

                                  context.read<PreferencesBloc>().add(
                                      UpdatePreferenceDF(
                                          attractionId: widget.attraction.id,
                                          currentPref: currentPref,
                                          action: 'save'));
                                }
                                for (var item in selectedTrips) {
                                  context
                                      .read<SavedServiceBloc>()
                                      .add(InsertSavedService(
                                        tripId: item.id,
                                        linkId: widget.attraction.id,
                                        cover: widget.attraction.cover,
                                        name: widget.attraction.name,
                                        locationName:
                                            widget.attraction.locationName,
                                        rating:
                                            widget.attraction.avgRating ?? 0,
                                        ratingCount:
                                            widget.attraction.ratingCount ?? 0,
                                        typeId: 2,
                                        price: widget.attraction.price,
                                        tagInfoList: widget
                                            .attraction.travelTypes
                                            ?.map((e) => e is String
                                                ? e
                                                : e['type_name'] as String)
                                            .toList(),
                                        latitude: widget.attraction.latitude,
                                        longitude: widget.attraction.longitude,
                                      ));
                                }

                                for (var item in unselectedTrips) {
                                  context
                                      .read<SavedServiceBloc>()
                                      .add(DeleteSavedService(
                                        linkId: widget.attraction.id,
                                        tripId: item.id,
                                      ));
                                }
                              },
                            ), null, false);
                          },
                          iconSize: 18,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove extra padding
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          icon: Icon(
                            currentSavedTripCount != null
                                ? currentSavedTripCount! > 0
                                    ? Icons.favorite
                                    : Icons.favorite_border
                                : widget.attraction.isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                            color: currentSavedTripCount != null
                                ? currentSavedTripCount! > 0
                                    ? Colors.redAccent
                                    : null
                                : widget.attraction.isSaved
                                    ? Colors.redAccent
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 190,
                        child: Text(
                          widget.attraction.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: widget.attraction.avgRating ?? 0,
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
                          Text(
                            '(${widget.attraction.ratingCount})',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.fire,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.attraction.hotScore.toString(),
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
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.attraction.distance != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            Text(
                              formatDistance(widget.attraction.distance!),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
