import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class ServiceBigCard extends StatefulWidget {
  final Service service;

  final String type;

  const ServiceBigCard({required this.service, super.key, required this.type});

  @override
  State<ServiceBigCard> createState() => _ServiceBigCardState();
}

class _ServiceBigCardState extends State<ServiceBigCard> {
  int? currentSavedTripCount;
  int changeSavedItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is SavedToTripLoadedSuccess) {
          // currentSavedTripCount =
          //     state.trips.where((trip) => trip.isSaved).length;
        }
      },
      child: InkWell(
        onTap: () {
          if (widget.type == 'Địa điểm du lịch') {
            Navigator.pushNamed(
              context,
              '/attraction',
              arguments: widget.service.id,
            );
          } else {
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
                        imageUrl: "${widget.service.cover}?w=90&h=90",
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
                    BlocBuilder<LocationInfoCubit, LocationInfoState>(
                      builder: (context, state) {
                        return Positioned(
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
                                    id: widget.service.id,
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
                                          locationName:
                                              state is LocationInfoAddressLoaded
                                                  ? state.cityName
                                                  : '',
                                          rating: widget.service.score,
                                          price:
                                              widget.service.avgPrice?.toInt(),
                                          ratingCount:
                                              widget.service.commentCount,
                                          tagInfoList: widget
                                              .service.tagInfoList
                                              ?.map((e) => e is String
                                                  ? e
                                                  : e['tagName'] as String)
                                              .toList(),
                                          typeId: widget.service.typeId,
                                          latitude: widget.service.latitude,
                                          longitude: widget.service.longitude,
                                        ));
                                  }

                                  for (var item in unselectedTrips) {
                                    context.read<SavedServiceBloc>().add(
                                        DeleteSavedService(
                                            linkId: widget.service.id,
                                            tripId: item.id));
                                  }
                                },
                              ), null, false);
                            },
                            style: IconButton.styleFrom(
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
                        );
                      },
                    ),
                    if (widget.service.hotScore != null)
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
                      ),
                    if (widget.type == "Khách sạn" &&
                        widget.service.star != null)
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
                            rating: widget.service.star!,
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
                        widget.service.name,
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
                            rating: widget.service.score,
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
                            '(${widget.service.aggreationCommentCount})',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Travel Types
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
                      const SizedBox(height: 6),
                      // Price
                      if (widget.service.avgPrice != null)
                        Text(
                          'Từ: ${NumberFormat('#,###').format(widget.service.avgPrice)} VND',
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
