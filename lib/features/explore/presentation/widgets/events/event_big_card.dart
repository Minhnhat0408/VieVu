import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';

class EventBigCard extends StatefulWidget {
  final Event event;
  const EventBigCard({super.key, required this.event});

  @override
  State<EventBigCard> createState() => _EventBigCardState();
}

class _EventBigCardState extends State<EventBigCard> {
  int changeSavedItemCount = 0;
  int? currentSavedTripCount;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationInfoCubit, LocationInfoState>(
      listener: (context, state) {
        if (state is LocationInfoGeoLoaded) {
          setState(() {
            log('Latitude and longitude are fetched');
            latitude = state.latitude;
            longitude = state.longitude;
          });
        }
      },
      child: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          if (state is SavedToTripLoadedSuccess) {
            currentSavedTripCount =
                state.trips.where((trip) => trip.isSaved).length;
          }
        },
        child: InkWell(
          onTap: () => openDeepLink(widget.event.deepLink),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image and Favorite Button
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image.network(
                          widget.event.image,
                          width: 280,
                          height: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const SizedBox(
                                width: 280,
                                height: 150,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                          errorBuilder: (context, url, error) =>
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
                                id: widget.event.id,
                                type: 'service'));

                            // If latitude and longitude are not available, fetch them
                            if (latitude == null || longitude == null) {
                              context
                                  .read<LocationInfoCubit>()
                                  .convertAddressToGeoLocation(
                                      widget.event.venue);
                            }

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
                                    if (latitude == null || longitude == null) {
                                      log('Latitude and longitude are null');
                                    } else {
                                      context
                                          .read<SavedServiceBloc>()
                                          .add(InsertSavedService(
                                            tripId: item.id,
                                            eventDate: DateTime.parse(
                                                widget.event.day),
                                            linkId: widget.event.id,
                                            externalLink: widget.event.deepLink,
                                            cover: widget.event.image,
                                            name: widget.event.name,
                                            locationName: widget.event.venue,
                                            rating: 0,
                                            ratingCount: 0,
                                            typeId: 5,
                                            latitude: latitude ??
                                                0, // Use fetched latitude
                                            longitude: longitude ??
                                                0, // Use fetched longitude
                                          ));
                                    }
                                  }

                                  for (var item in unselectedTrips) {
                                    context.read<SavedServiceBloc>().add(
                                        DeleteSavedService(
                                            linkId: widget.event.id,
                                            tripId: item.id));
                                  }
                                },
                              ),
                              null,
                              false,
                            );
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
                                : widget.event.isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                            color: currentSavedTripCount != null
                                ? currentSavedTripCount! > 0
                                    ? Colors.redAccent
                                    : null
                                : widget.event.isSaved
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
                        Text(
                          widget.event.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.event.isFree
                              ? 'Miễn phí'
                              : 'Từ: ${NumberFormat('#,###').format(widget.event.price)} VND',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(widget.event.day)),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
