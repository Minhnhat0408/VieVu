import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';

import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_location/trip_location_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';

class SavedServiceSmallCard extends StatefulWidget {
  final ExploreSearchResult result;
  final Function onSavedChange;

  final bool isDetailed;

  const SavedServiceSmallCard({
    super.key,
    required this.onSavedChange,
    required this.result,
    this.isDetailed = false,
  });

  @override
  State<SavedServiceSmallCard> createState() => _SavedServiceSmallCardState();
}

class _SavedServiceSmallCardState extends State<SavedServiceSmallCard> {
  bool isSaved = false;
  @override
  void initState() {
    super.initState();
    isSaved = widget.result.isSaved;
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return const Icon(
          Icons.attractions,
          size: 40,
        );
      case 'locations':
        return const Icon(
          Icons.place,
          size: 40,
        );
      case 'keyword':
        return const Icon(
          Icons.search,
          size: 40,
        );

      default:
        return const FaIcon(
          FontAwesomeIcons.locationArrow,
          size: 40,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('result: ${result?.title}');
    return MultiBlocListener(
      listeners: [
        BlocListener<AttractionDetailsCubit, AttractionDetailsState>(
          listener: (context, state) {
            if (state is AttractionDetailsLoadedSuccess &&
                widget.result.id == state.attraction.id) {
              final tripId = (context.read<TripDetailsCubit>().state
                      as TripDetailsLoadedSuccess)
                  .trip
                  .id;
              context.read<SavedServiceBloc>().add(
                    InsertSavedService(
                      tripId: tripId,
                      linkId: state.attraction.id,
                      externalLink: state.attraction.externalLink,
                      cover: state.attraction.cover,
                      name: state.attraction.name,
                      locationName: state.attraction.locationName,
                      tagInfoList: state.attraction.travelTypes
                          ?.map(
                              (e) => e is String ? e : e['type_name'] as String)
                          .toList(),
                      latitude: state.attraction.latitude,
                      longitude: state.attraction.longitude,
                      rating: state.attraction.avgRating ?? 0,
                      ratingCount: state.attraction.ratingCount ?? 0,
                      typeId: 2,
                      price: state.attraction.price,
                    ),
                  );

              context.read<TripLocationBloc>().add(InsertTripLocation(
                    locationId: state.attraction.locationId,
                    tripId: tripId,
                  ));
            }
          },
        ),
        BlocListener<LocationBloc, LocationState>(listener: (context, state) {
          if (state is LocationDetailsLoadedSuccess &&
              widget.result.id == state.location.id) {
            final tripId = (context.read<TripDetailsCubit>().state
                    as TripDetailsLoadedSuccess)
                .trip
                .id;
            context.read<TripLocationBloc>().add(InsertTripLocation(
                  locationId: state.location.id,
                  tripId: tripId,
                ));
          }
        }),
        BlocListener<LocationInfoCubit, LocationInfoState>(
            listener: (context, state) {
          if (state is LocationInfoGeoLoaded &&
              widget.result.id == state.linkId) {
            final tripId = (context.read<TripDetailsCubit>().state
                    as TripDetailsLoadedSuccess)
                .trip
                .id;

            context.read<SavedServiceBloc>().add(
                  InsertSavedService(
                    tripId: tripId,
                    linkId: widget.result.id,
                    externalLink: widget.result.externalLink,
                    cover: widget.result.cover!,
                    name: widget.result.title,
                    locationName: widget.result.locationName!,
                    tagInfoList: null,
                    latitude: state.latitude,
                    longitude: state.longitude,
                    rating: widget.result.avgRating ?? 0,
                    ratingCount: widget.result.ratingCount ?? 0,
                    typeId: widget.result.type == 'hotel' ? 4 : 1,
                    price: widget.result.price,
                  ),
                );

            context.read<TripLocationBloc>().add(InsertTripLocation(
                  locationId: state.locationId,
                  tripId: tripId,
                ));
          }
        }),
        BlocListener<EventBloc, EventState>(listener: (context, state) {
          if (state is EventDetailsLoadedSuccess &&
              widget.result.id == state.event.id) {
            final tripId = (context.read<TripDetailsCubit>().state
                    as TripDetailsLoadedSuccess)
                .trip
                .id;
            context.read<SavedServiceBloc>().add(
                  InsertSavedService(
                    tripId: tripId,
                    linkId: state.event.id,
                    externalLink: state.event.deepLink,
                    cover: state.event.image,
                    name: state.event.name,
                    locationName: state.event.locationName!,
                    tagInfoList: null,
                    latitude: state.event.latitude!,
                    longitude: state.event.longitude!,
                    typeId: 5,
                    rating: 0,
                    ratingCount: 0,
                    eventDate: DateTime.parse(state.event.day),
                    price: state.event.price,
                  ),
                );

            context.read<TripLocationBloc>().add(InsertTripLocation(
                  locationId: state.event.locationId!,
                  tripId: tripId,
                ));
          }
        }),
      ],
      child: InkWell(
        onTap: () async {
          // Navigate to the detail page
          final tripId = (context.read<TripDetailsCubit>().state
                  as TripDetailsLoadedSuccess)
              .trip
              .id;

          final userId =
              (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
          if (widget.result.type == 'event') {
            // openDeepLink(widget.result.id);
            if (isSaved) {
              context.read<SavedServiceBloc>().add(
                    DeleteSavedService(
                      tripId: tripId,
                      linkId: widget.result.id,
                    ),
                  );
            } else {
              context.read<EventBloc>().add(
                    GetEventDetails(
                      eventId: widget.result.id,
                    ),
                  );
            }
          } else if (widget.result.type == 'attractions') {
            if (isSaved) {
              context.read<SavedServiceBloc>().add(
                    DeleteSavedService(
                      tripId: tripId,
                      linkId: widget.result.id,
                    ),
                  );
            } else {
              context
                  .read<AttractionDetailsCubit>()
                  .fetchAttractionDetails(widget.result.id);
            }
          } else if (widget.result.type == 'hotel' ||
              widget.result.type == 'restaurant' ||
              widget.result.type == 'shop') {
            if (isSaved) {
              context.read<SavedServiceBloc>().add(
                    DeleteSavedService(
                      tripId: tripId,
                      linkId: widget.result.id,
                    ),
                  );
            } else {
              context.read<LocationInfoCubit>().convertAddressToGeoLocation(
                  widget.result.title, widget.result.id);
            }

            // check if result.id contains http or https if not add https://vn.trip.com
          } else if (widget.result.type == 'locations') {
            if (isSaved) {
              context.read<SavedServiceBloc>().add(
                    DeleteSavedService(
                      tripId: tripId,
                      linkId: widget.result.id,
                    ),
                  );
            } else {
              context.read<LocationBloc>().add(
                    GetLocation(locationId: widget.result.id),
                  );
            }
          }

          setState(() {
            isSaved = !isSaved;
          });
          widget.onSavedChange(isSaved);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    width: 2.0,
                  ),
                ),
                width: 90,
                height: 90,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: "${widget.result.cover}", // Use optimized size
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      fadeInDuration: Duration
                          .zero, // Remove fade-in animation for faster display
                      filterQuality: FilterQuality.low,
                      useOldImageOnUrlChange: true, // Avoid unnecessary reloads
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          onPressed: () {},
                          iconSize: 18,
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove extra padding
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.redAccent : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                // Ensure this widget allows text to take available space
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.result == null
                            ? 'Lân cận'
                            : widget.result.type == 'keyword'
                                ? '"${widget.result.title}"'
                                : widget.result.title,
                        minFontSize: 14, // Minimum font size to shrink to
                        maxLines: 2, // Allow up to 2 lines for wrapping
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if it exceeds maxLines
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Default starting font size
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.isDetailed &&
                          (widget.result.type == 'attractions' ||
                              widget.result.type == 'hotel' ||
                              widget.result.type == 'restaurant' ||
                              widget.result.type == 'shop'))
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: widget.result.avgRating ?? 0,
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
                              '(${widget.result.ratingCount ?? 0})',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 10),
                            if (widget.result.hotScore != null)
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.result.hotScore.toString() ?? '0',
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
                      if (widget.result.address != null)
                        Text(
                          widget.result.address!,
                          softWrap: true, // Wrap the address to the next line
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
