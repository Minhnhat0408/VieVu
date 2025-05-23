import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/domain/entities/service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final String type;
  final bool slider;
  const ServiceCard({
    super.key,
    required this.service,
    required this.type,
    this.slider = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
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
          log(widget.type);
          if (widget.type == 'Địa điểm du lịch') {
            Navigator.pushNamed(
              context,
              '/attraction',
              arguments: widget.service.id,
            );
          } else {
            //check if service.jumpUrl contains http or https if not add https://vn.trip.com
            if (widget.service.jumpUrl.contains('http') ||
                widget.service.jumpUrl.contains('https')) {
              openDeepLink(widget.service.jumpUrl);
            } else {
              final String url = 'https://vn.trip.com${widget.service.jumpUrl}';
              openDeepLink(url);
            }
          }
        },
        child: Card(
          elevation: 0,
          color: widget.slider
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : Colors.transparent,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: Row(
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
                        child: Image.network(
                          widget.service.cover,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
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
                              final userId = (context.read<AppUserCubit>().state
                                      as AppUserLoggedIn)
                                  .user
                                  .id;

                              String locationName;
                              if (!widget.slider) {
                                locationName = (context
                                            .read<AttractionDetailsCubit>()
                                            .state
                                        as AttractionDetailsLoadedSuccess)
                                    .attraction
                                    .locationName;
                              } else {
                                locationName = (context
                                        .read<LocationInfoCubit>()
                                        .state as LocationInfoAddressLoaded)
                                    .cityName;
                              }

                              context.read<TripBloc>().add(GetSavedToTrips(
                                    userId: userId,
                                    id: widget.service.id,
                                  ));

                              log('ServiceCard: ${widget.service.id}');
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
                                  if (selectedTrips.isNotEmpty &&
                                      widget.type == 'Địa điểm du lịch') {
                                    final currentPref = (context
                                            .read<PreferencesBloc>()
                                            .state as PreferencesLoadedSuccess)
                                        .preference;

                                    context.read<PreferencesBloc>().add(
                                        UpdatePreferenceDF(
                                            attractionId: widget.service.id,
                                            currentPref: currentPref,
                                            action: 'save'));
                                  }
                                  for (var item in selectedTrips) {
                                    context
                                        .read<SavedServiceBloc>()
                                        .add(InsertSavedService(
                                          tripId: item.id,
                                          linkId: widget.service.id,
                                          cover: widget.service.cover,
                                          name: widget.service.name,
                                          locationName: locationName,
                                          externalLink: widget.service.jumpUrl,
                                          rating: widget.service.score,
                                          ratingCount:
                                              widget.service.commentCount,
                                          typeId: widget.service.typeId,
                                          hotelStar:
                                              widget.service.star?.toInt(),
                                          price:
                                              widget.service.avgPrice?.toInt(),
                                          tagInfoList: widget
                                              .service.tagInfoList
                                              ?.map((item) => item is String
                                                  ? item
                                                  : item['tagName'].toString())
                                              .toList(),
                                          latitude: widget.service.latitude,
                                          longitude: widget.service.longitude,
                                        ));
                                  }

                                  for (var item in unselectedTrips) {
                                    context
                                        .read<SavedServiceBloc>()
                                        .add(DeleteSavedService(
                                          tripId: item.id,
                                          linkId: widget.service.id,
                                        ));
                                  }
                                },
                              ), null, false);
                            },
                            iconSize: 18,
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero, // Remove extra padding
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
                                  : widget.service.isSaved
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                              color: currentSavedTripCount != null
                                  ? currentSavedTripCount! > 0
                                      ? Colors.redAccent
                                      : null
                                  : widget.service.isSaved
                                      ? Colors.redAccent
                                      : null,
                            ),
                          ),
                        ),
                      ),
                      if (widget.type == 'Địa điểm du lịch' && widget.slider)
                        Positioned(
                            bottom: 4,
                            left: 4,
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
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.fire,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.service.hotScore.toString(),
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
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // Ensure this widget allows text to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
                        if (widget.service.tagInfoList != null)
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
                              widget.service.tagInfoList![0]['tagName'] ?? '',
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: widget.service.score,
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
                                  '(${widget.service.commentCount})',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            if (widget.type == 'Khách sạn' &&
                                widget.service.star != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.service.star.toString()[0],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star,
                                        size: 20,
                                        color:
                                            Color.fromARGB(255, 255, 234, 44)),
                                  ],
                                ),
                              ),
                            if (widget.type == 'Địa điểm du lịch' &&
                                !widget.slider)
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
                                      widget.service.hotScore.toString(),
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
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.service.distanceDesc != null)
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
                                      widget.service.distanceDesc!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              if (widget.service.avgPrice != null &&
                                  !widget.slider)
                                Text(
                                  '${NumberFormat('#,###').format(widget.service.avgPrice)} VND',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
