import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_info_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_itinerary_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_saved_services_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_members_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_detail_appbar.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

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
  bool isFavorite = false;
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
  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: widget.initialIndex ?? 0,
      length: 4,
      vsync: this,
    );
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 1) {
          setState(() {
            isFavorite = true;
          });
        } else {
          setState(() {
            isFavorite = false;
          });
        }
      }
    });
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
          }
          if (state is TripDetailsLoadedFailure) {
            showSnackbar(context, state.message, 'error');
          }
        },
        builder: (context, state) {
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
                          BlocProvider(
                            create: (context) =>
                                serviceLocator<LocationInfoCubit>(),
                            child: TripSavedServicesPage(trip: trip!,
                            currentUser: currentUser,),
                          ),
                          TripItineraryPage(trip: trip!,
                          currentUser: currentUser,),
                          TripMembersPage(trip: trip!,
                          ),
                        ])
                      : const Center(child: CircularProgressIndicator())),

              // Positioned.fill(
              //     child: CircularMenu(
              //         toggleButtonColor:
              //             Theme.of(context).colorScheme.primaryContainer,
              //         alignment: const Alignment(0.95, 0.85),
              //         toggleButtonIconColor:
              //             Theme.of(context).colorScheme.primary,
              //         startingAngleInRadian:
              //             3.14, // Example: 180 degrees (π radians)
              //         endingAngleInRadian:
              //             3.14 * 3 / 2, // Example: 360 degrees (2π radians)
              //         items: [
              //       CircularMenuItem(
              //           color: Theme.of(context).colorScheme.primaryContainer,
              //           icon: Icons.message,
              //           iconColor: Theme.of(context).colorScheme.primary,
              //           onTap: () {
              //             // callback
              //           }),
              //       CircularMenuItem(
              //         color: Theme.of(context).colorScheme.primaryContainer,
              //         icon: Icons.map_outlined,
              //         onTap: () {
              //           //callback
              //         },
              //         iconColor: Theme.of(context).colorScheme.primary,
              //       ),
              //       CircularMenuItem(
              //           color: Theme.of(context).colorScheme.primaryContainer,
              //           icon: Icons.people_alt,
              //           iconColor: Theme.of(context).colorScheme.primary,
              //           onTap: () {
              //             //callback
              //           }),
              //     ]))
            ]),
          );
        },
      ),
    );
  }
}
