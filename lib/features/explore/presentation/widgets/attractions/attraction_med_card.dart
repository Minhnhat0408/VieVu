import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';

class AttractionMedCard extends StatefulWidget {
  final Attraction attraction;
  final bool slider;
  const AttractionMedCard({
    super.key,
    required this.attraction,
    this.slider = false,
  });

  @override
  State<AttractionMedCard> createState() => _AttractionMedCardState();
}

class _AttractionMedCardState extends State<AttractionMedCard> {
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
            color: widget.slider
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Colors.transparent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
              child: Row(
                crossAxisAlignment: widget.slider
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  // Image and Icon
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              widget.attraction.cover, // Use optimized size
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          fadeInDuration: Duration
                              .zero, // Remove fade-in animation for faster display
                          filterQuality: FilterQuality.low,
                          useOldImageOnUrlChange:
                              true, // Avoid unnecessary reloads
                          width: 110,
                          height: 110,
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
                              displayModal(
                                  context,
                                  SavedToTripModal(

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
                                              linkId: widget.attraction.id,
                                              cover: widget.attraction.cover,
                                              name: widget.attraction.name,
                                              locationName: widget
                                                  .attraction.locationName,
                                              rating:
                                                  widget.attraction.avgRating ??
                                                      0,
                                              ratingCount: widget
                                                      .attraction.ratingCount ??
                                                  0,
                                              typeId: 2,
                                              price: widget.attraction.price,
                                              tagInfoList: widget
                                                  .attraction.travelTypes
                                                  ?.map((e) => e is String
                                                      ? e
                                                      : e['type_name']
                                                          .toString())
                                                  .toList(),
                                              latitude:
                                                  widget.attraction.latitude,
                                              longitude:
                                                  widget.attraction.longitude,
                                            ));


                                      }

                                      for (var item in unselectedTrips) {
                                        context.read<SavedServiceBloc>().add(
                                            DeleteSavedService(
                                                linkId: widget.attraction.id,
                                                tripId: item.id));
                                      }
                                    },
                                  ),
                                  null,
                                  false);
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
                      if (widget.slider)
                        Positioned(
                            bottom: 8,
                            left: 8,
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
                            )),
                    ],
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
                            widget.attraction.name,
                            minFontSize: 14, // Minimum font size to shrink to
                            maxLines: 1, // Allow up to 2 lines for wrapping
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis if it exceeds maxLines
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Default starting font size
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.attraction.travelTypes != null)
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
                                widget.attraction.travelTypes![0]
                                        ['type_name'] ??
                                    '',
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: widget.attraction.avgRating ?? 0,
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
                                '(${widget.attraction.ratingCount})',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              if (!widget.slider)
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                          if (widget.attraction.price != null)
                            Text(
                              '${NumberFormat('#,###').format(widget.attraction.price)} VND',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
