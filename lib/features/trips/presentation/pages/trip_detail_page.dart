import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/onboarding_help.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_review_bloc.dart';
import 'package:vievu/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vievu/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vievu/features/trips/presentation/pages/location_shared_map.dart';
import 'package:vievu/features/trips/presentation/pages/trip_info_page.dart';
import 'package:vievu/features/trips/presentation/pages/trip_itinerary_page.dart';
import 'package:vievu/features/trips/presentation/pages/trip_review_page.dart';
import 'package:vievu/features/trips/presentation/pages/trip_saved_services_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/presentation/pages/trip_members_page.dart';
import 'package:vievu/features/trips/presentation/widgets/modals/post_review_modal.dart';
import 'package:vievu/features/trips/presentation/widgets/trip_detail_appbar.dart';
import 'package:vievu/init_dependencies.dart';

class TripDetailPage extends StatefulWidget {
  static const String routeName = '/trip-detail';
  final String? tripCover;
  final int? initialIndex;
  final String tripId;
  const TripDetailPage(
      {super.key, this.tripCover, required this.tripId, this.initialIndex});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  Trip? trip;
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  TripMember? currentUser;
  List<TripMember> tripMembers = [];
  List<TripItinerary> tripItineraries = [];
  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: widget.initialIndex ?? 0,
      length: 4,
      vsync: this,
    );
    context.read<TripReviewBloc>().add(GetTripReviews(tripId: widget.tripId));

    context.read<TripDetailsCubit>().getTripDetails(tripId: widget.tripId);
    context
        .read<SavedServiceBloc>()
        .add(GetSavedServices(tripId: widget.tripId));
    context.read<CurrentTripMemberInfoCubit>().loadTripMemberToTrip(
          tripId: widget.tripId,
        );
    context
        .read<TripItineraryBloc>()
        .add(GetTripItineraries(tripId: widget.tripId));
    context.read<TripMemberBloc>().add(GetTripMembers(tripId: widget.tripId));
  }

  @override
  void dispose() {
    tabController.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TripDetailsCubit, TripDetailsState>(
        listener: (context, state) {
          if (state is TripDetailsLoadedSuccess) {
            setState(() {
              trip = state.trip;
            });

            if (trip!.status == 'completed') {
              // tabController.dispose();
              tabController = TabController(
                initialIndex: widget.initialIndex ?? 0,
                length: 5,
                vsync: this,
              );
            }
          }
        },
        builder: (context, state) {
          if (state is TripDetailsLoadedFailure) {
            log(state.message);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết chuyến đi'),
              ),
              body: Center(
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Không thể truy cập chuyến đi này",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<TripBloc, TripState>(
                listener: (context, state) {
                  if (state is TripActionSuccess) {
                    setState(() {
                      trip = state.trip;
                    });
                  }
                },
              ),
              BlocListener<SavedServiceBloc, SavedServiceState>(
                listener: (context, state) {
                  if (state is SavedServiceActionSucess) {
                    // check if the location is already in the trip
                    if (trip != null &&
                        !trip!.locations
                            .contains(state.savedService.locationName)) {
                      setState(() {
                        trip!.locations.add(state.savedService.locationName);
                      });
                    }
                  }
                },
              ),
              BlocListener<TripItineraryBloc, TripItineraryState>(
                listener: (context, state) {
                  if (state is TripItineraryLoadedSuccess) {
                    if (trip != null) {
                      setState(() {
                        trip!.hasTripItineraries =
                            state.tripItineraries.isNotEmpty;
                      });
                    }
                    tripItineraries = state.tripItineraries;
                  }
                },
              ),
              BlocListener<CurrentTripMemberInfoCubit,
                  CurrentTripMemberInfoState>(
                listener: (context, state) {
                  if (state is CurrentTripMemberInfoLoaded) {
                    setState(() {
                      currentUser = state.tripMember;
                    });
                    log('mounted');
                    // log(currentUser!.reviewed.toString());
                    if (currentUser?.reviewed == false &&
                        trip?.status == 'completed') {
                      OnboardingHelper.hasSeenTripReviewGuide().then((value) {
                        if (!value) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Chuyến đi hoàn tất",
                                textAlign: TextAlign.center,
                              ),
                              actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/celeb1.png',
                                    // width: 200,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text("Đánh giá trải nghiệm"),
                                  RatingBarIndicator(
                                    rating: 0,
                                    itemSize: 50,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        displayModal(
                                          context,
                                          PostReviewModal(
                                            trip: trip!,
                                            currentUser: currentUser!,
                                            initialRating: index + 1,
                                          ),
                                          null,
                                          true,
                                        ).then((value) {
                                          tabController.animateTo(1);
                                        });
                                      },
                                      child: Icon(
                                        Icons.star_border,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Để sau"),
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    }
                  }
                },
              ),
              BlocListener<TripMemberBloc, TripMemberState>(
                listener: (context, state) {
                  if (state is TripMemberLoadedSuccess) {
                    setState(() {
                      tripMembers = state.tripMembers;
                    });
                  }
                  if (state is TripMemberFailure) {
                    showSnackbar(context, state.message, 'error');
                  }
                  if (state is TripMemberInsertedSuccess) {
                    showSnackbar(context, 'Tham gia chuyến đi thành công!',
                        SnackBarState.success);
                  }
                },
              ),
            ],
            child: Stack(children: [
              NestedScrollView(
                  floatHeaderSlivers: false,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverOverlapAbsorber(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                            sliver: TripDetailAppbar(
                              trip: trip,
                              tripCover: widget.tripCover,
                              tripId: widget.tripId,
                              tabController: tabController,
                            )),
                      ],
                  body: trip != null
                      ? TabBarView(controller: tabController, children: [
                          TripInfoPage(trip: trip!),
                          if (tabController.length == 5 &&
                              trip!.status == 'completed')
                            TripReviewPage(
                              trip: trip!,
                              currentUser: currentUser,
                            ),
                          BlocProvider(
                            create: (context) =>
                                serviceLocator<LocationInfoCubit>(),
                            child: TripSavedServicesPage(
                              trip: trip!,
                              currentUser: currentUser,
                            ),
                          ),
                          TripItineraryPage(
                            trip: trip!,
                            currentUser: currentUser,
                          ),
                          TripMembersPage(
                            trip: trip!,
                          ),
                        ])
                      : const Center(child: CircularProgressIndicator())),
              if (currentUser != null && trip?.status == 'ongoing')
                Positioned(
                    bottom: 70,
                    right: 10,
                    child: FilledButton.icon(
                        onPressed: () async {
                          LocationPermission permission =
                              await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied ||
                              permission == LocationPermission.deniedForever) {
                            showSnackbar(
                                context,
                                'Vui lòng bật dịch vụ định vị để sử dụng',
                                SnackBarState.warning);
                            return;
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationSharedMap(
                                    tripId: widget.tripId,
                                    tripItineraries:
                                        tripItineraries.where((element) {
                                      final now = DateTime.now().toUtc();
                                      final today = DateTime.utc(now.year,
                                          now.month, now.day, 0, 0, 0);

                                      return element.time.isAfter(today) &&
                                          element.time.isBefore(today
                                              .add(const Duration(days: 1)));
                                    }).toList(),
                                  ),
                                ));
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Chia sẻ vị trí'))),
            ]),
          );
        },
      ),
    );
  }
}
