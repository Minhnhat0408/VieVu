import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class AttractionBigCard extends StatefulWidget {
  final Attraction attraction;
  final Function? onSavedChanged;

  const AttractionBigCard(
      {required this.attraction, super.key, this.onSavedChanged});

  @override
  State<AttractionBigCard> createState() => _AttractionBigCardState();
}

class _AttractionBigCardState extends State<AttractionBigCard> {
  int changeSavedItemCount = 0;
  int? currentSavedTripCount;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    isSaved = widget.attraction.isSaved;
  }

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
          // Navigate to Attraction Details Page
          if (widget.attraction.latitude != 0) {
            Navigator.pushNamed(context, '/attraction',
                arguments: widget.attraction.id);
          } else if (widget.attraction.externalLink != null) {
            openDeepLink(widget.attraction.externalLink!);
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
                        imageUrl: "${widget.attraction.cover}?w=90&h=90",
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
                                  if (currentSavedTripCount! > 0) {
                                    isSaved = true;
                                  } else {
                                    isSaved = false;
                                  }
                                });
                                if (widget.onSavedChanged != null) {
                                  widget.onSavedChanged!(
                                      currentSavedTripCount! > 0);
                                }
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
                                            .attraction.travelTypes!
                                            .map((e) => e is String
                                                ? e
                                                : e['type_name'] as String)
                                            .toList(),
                                        latitude: widget.attraction.latitude,
                                        longitude: widget.attraction.longitude,
                                      ));
                                }

                                for (var item in unselectedTrips) {
                                  context.read<SavedServiceBloc>().add(
                                      DeleteSavedService(
                                          linkId: widget.attraction.id,
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
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.redAccent : null,
                          )),
                    ),
                    if (widget.attraction.rankInfo != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            'assets/images/tripbest.png',
                            width: 75,
                            height: 25,
                          ),
                        ),
                      ),
                    if (widget.attraction.hotScore > 0)
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
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.attraction.name,
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
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Travel Types
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.attraction.travelTypes!
                            .take(2)
                            .map<Widget>((travelType) {
                          return Container(
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
                              travelType is String
                                  ? travelType
                                  : travelType['type_name'],
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      // Price
                      if (widget.attraction.price != null)
                        Text(
                          'Từ: ${NumberFormat('#,###').format(widget.attraction.price)} VND',
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
