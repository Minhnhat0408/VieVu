import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/reviews/reviews_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/related_attraction_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/nearby_service_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/open_time_display.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/reviews/reviews_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/slider_pagination.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_location/trip_location_bloc.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class AttractionDetailPage extends StatelessWidget {
  final int attractionId;

  const AttractionDetailPage({super.key, required this.attractionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AttractionDetailsCubit>(),
        ),
        BlocProvider(create: (_) => serviceLocator<NearbyServicesCubit>()),
        BlocProvider(create: (_) => serviceLocator<ReviewsCubit>()),
      ],
      child: Scaffold(
        body: AttractionDetailView(attractionId: attractionId),
      ),
    );
  }
}

class AttractionDetailView extends StatefulWidget {
  final int attractionId;

  const AttractionDetailView({
    super.key,
    required this.attractionId,
  });

  @override
  State<AttractionDetailView> createState() => _AttractionDetailViewState();
}

class _AttractionDetailViewState extends State<AttractionDetailView> {
  int activeIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewsSectionKey = GlobalKey();
  int changeSavedItemCount = 0;
  bool _showFullDescription = false;
  int currentSavedTripCount = 0;
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<TripBloc>().add(GetSavedToTrips(
        userId: userId, id: widget.attractionId, type: 'service'));
    context
        .read<AttractionDetailsCubit>()
        .fetchAttractionDetails(widget.attractionId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Địa điểm du lịch',
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share the attraction
          },
        ),
        BlocListener<TripBloc, TripState>(
          listener: (context, state) {
            if (state is SavedToTripLoadedSuccess) {
              log('SavedToTripLoadedSuccess');
              currentSavedTripCount =
                  state.trips.where((trip) => trip.isSaved).length;
            }
          },
          child: BlocBuilder<AttractionDetailsCubit, AttractionDetailsState>(
            builder: (context, state) {
              return IconButton(
                  onPressed: () {
                    if (state is AttractionDetailsLoadedSuccess) {
                      final userId = (context.read<AppUserCubit>().state
                              as AppUserLoggedIn)
                          .user
                          .id;
                      context.read<TripBloc>().add(GetSavedToTrips(
                          userId: userId,
                          id: state.attraction.id,
                          type: 'service'));
                      displayModal(
                          context,
                          SavedToTripModal(
                            type: "service",
                            onTripsChanged: (List<Trip> selectedTrips,
                                List<Trip> unselectedTrips) {
                              setState(() {
                                changeSavedItemCount = selectedTrips.length +
                                    unselectedTrips.length;

                                currentSavedTripCount = currentSavedTripCount +
                                    selectedTrips.length -
                                    unselectedTrips.length;
                              });

                              for (var item in selectedTrips) {
                                context
                                    .read<SavedServiceBloc>()
                                    .add(InsertSavedService(
                                      tripId: item.id,
                                      linkId: state.attraction.id,
                                      cover: state.attraction.cover,
                                      name: state.attraction.name,
                                      locationName:
                                          state.attraction.locationName,
                                      rating: state.attraction.avgRating ?? 0,
                                      ratingCount:
                                          state.attraction.ratingCount ?? 0,
                                      typeId: 2,
                                      tagInfoList: state.attraction.travelTypes!
                                          .map((e) => e['type_name'].toString())
                                          .toList(),

                                      latitude: state.attraction.latitude,
                                      longitude: state.attraction.longitude,
                                    ));

                                context
                                    .read<TripLocationBloc>()
                                    .add(InsertTripLocation(
                                      locationId: state.attraction.locationId,
                                      tripId: item.id,
                                    ));
                              }

                              for (var item in unselectedTrips) {
                                context.read<SavedServiceBloc>().add(
                                    DeleteSavedService(
                                        linkId: state.attraction.id,
                                        tripId: item.id));
                              }
                            },
                          ),
                          null,
                          false);
                    }
                  },
                  icon: Icon(
                    currentSavedTripCount > 0
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: currentSavedTripCount > 0 ? Colors.redAccent : null,
                  ));
            },
          ),
        ),
      ],
      body: BlocConsumer<AttractionDetailsCubit, AttractionDetailsState>(
        listener: (context, state) {
          if (state is AttractionDetailsFailure) {
            // Show error message
            showSnackbar(context, state.message, 'error');
          }
        },
        builder: (context, state) {
          if (state is AttractionDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is AttractionDetailsLoadedSuccess) {
            final Attraction attraction = state.attraction;
            final imgList = attraction.images != null
                ? [...?attraction.images, attraction.cover]
                : [attraction.cover];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      SliderPagination(imgList: imgList),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.fire,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  attraction.hotScore.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attraction.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: attraction.avgRating ?? 0,
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
                            const SizedBox(width: 8),
                            Text(
                              '${attraction.avgRating}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                                onTap: () {
                                  final context =
                                      _reviewsSectionKey.currentContext;
                                  if (context != null) {
                                    Scrollable.ensureVisible(
                                      context,
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Text(
                                  '${NumberFormat('#,###').format(attraction.ratingCount)} đánh giá',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (attraction.rankInfo != null)
                          Text(
                            "${attraction.rankInfo?['description']}",
                            style: TextStyle(
                                height: 1.8,
                                fontSize: 16,
                                fontFamily:
                                    GoogleFonts.merriweather().fontFamily,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              attraction.travelTypes!.map<Widget>((travelType) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Text(
                                travelType['type_name'] ?? '',
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _showFullDescription
                                    ? attraction.description
                                    : attraction.description.length > 100
                                        ? '${attraction.description.substring(0, 100)}...'
                                        : attraction
                                            .description, // Adjust length
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              if (!_showFullDescription &&
                                  attraction.description.length > 100)
                                TextSpan(
                                  text: ' Xem thêm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() {
                                        _showFullDescription = true;
                                      });
                                    },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        OpenTimeDisplay(
                            openTimeRules: attraction.openTimeRule ?? []),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: const FaIcon(FontAwesomeIcons.locationDot,
                                  size: 18),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              // Use Flexible or Expanded here

                              child: Text(
                                '${attraction.address}',
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (attraction.phone != null)
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const FaIcon(FontAwesomeIcons.phone,
                                    size: 18),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                // Use Flexible or Expanded here

                                child: Text(
                                  '${attraction.phone}',
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        const Divider(
                          thickness: 1.5,
                          height: 40,
                        ),
                        const SizedBox(height: 20),
                        NearbyServiceSection(
                          attractionId: widget.attractionId,
                          attractionName: attraction.name,
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          thickness: 1.5,
                          height: 40,
                        ),
                        const SizedBox(height: 12),
                        ReviewsSection(
                          serviceId: widget.attractionId,
                          totalReviews: attraction.ratingCount ?? 0,
                          reviewsSectionKey: _reviewsSectionKey,
                          avgRating: attraction.avgRating,
                        ),
                        const SizedBox(height: 20),
                        BlocProvider(
                          create: (_) => serviceLocator<AttractionBloc>(),
                          child: RelatedAttractionSection(
                              attractionId: widget.attractionId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Không tìm thấy dữ liệu'),
          );
        },
      ),
    );
  }
}
