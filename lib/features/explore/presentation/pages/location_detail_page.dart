import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/hotel_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/restaurant_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_location/trip_location_bloc.dart';
import 'package:vn_travel_companion/init_dependencies.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/restaurant_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/sub_location_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/tripbest_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/slider_pagination.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/attraction_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/comment_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/hotel_section.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';

class LocationDetailPage extends StatelessWidget {
  final int locationId;
  final String locationName;
  const LocationDetailPage(
      {super.key, required this.locationId, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<LocationBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<LocationInfoCubit>(),
        ),
      ],
      child: Scaffold(
        body: LocationDetailMain(
          locationId: locationId,
          locationName: locationName,
        ),
      ),
    );
  }
}

class LocationDetailMain extends StatefulWidget {
  final int locationId;
  final String locationName;

  const LocationDetailMain(
      {super.key, required this.locationId, required this.locationName});

  @override
  State<LocationDetailMain> createState() => LocationDetailMainState();
}

class LocationDetailMainState extends State<LocationDetailMain> {
  int _selectedIndex = 0;
  bool reversedTrans = false;
  bool _dialogShown = false; // Track if the dialog is already shown
  bool mapView = false;
  double? latitude;
  double? longitude;
  int changeSavedItemCount = 0;
  int currentSavedTripCount = 0;

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<TripBloc>().add(GetSavedToTrips(
        userId: userId, id: widget.locationId, type: 'location'));
    context
        .read<LocationBloc>()
        .add(GetLocation(locationId: widget.locationId));
    context.read<LocationInfoCubit>().fetchLocationInfo(widget.locationId);
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex > index) {
        reversedTrans = true;
      } else {
        reversedTrans = false;
      }
      _selectedIndex = index;
    });
  }

  final options = [
    "Tổng quan",
    "Địa điểm du lịch",
    "Nhà hàng",
    "Khách sạn",
  ];

  // Replace with the desired icons
  IconData _convertIcon(int index) {
    switch (index) {
      case 0:
        return Icons.info_outline;
      case 1:
        return Icons.attractions;
      case 2:
        return Icons.restaurant;
      case 3:
        return Icons.hotel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is SavedToTripLoadedSuccess) {
          currentSavedTripCount =
              state.trips.where((trip) => trip.isSaved).length;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.locationName),
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Scroll slightly down to make the bottom visible
              },
            ),
            IconButton(
                onPressed: () {
                  final userId =
                      (context.read<AppUserCubit>().state as AppUserLoggedIn)
                          .user
                          .id;
                  context.read<TripBloc>().add(GetSavedToTrips(
                      userId: userId, id: widget.locationId, type: 'location'));
                  displayModal(context, SavedToTripModal(
                    onTripsChanged:
                        (List<Trip> selectedTrips, List<Trip> unselectedTrips) {
                      setState(() {
                        changeSavedItemCount =
                            selectedTrips.length + unselectedTrips.length;

                        currentSavedTripCount = currentSavedTripCount +
                            selectedTrips.length -
                            unselectedTrips.length;
                      });
                      for (var item in selectedTrips) {
                        context.read<TripLocationBloc>().add(InsertTripLocation(
                              locationId: widget.locationId,
                              tripId: item.id,
                            ));
                      }

                      for (var item in unselectedTrips) {
                        context.read<TripLocationBloc>().add(DeleteTripLocation(
                              locationId: widget.locationId,
                              tripId: item.id,
                            ));
                      }
                    },
                  ), null, false);
                },
                icon: Icon(
                  currentSavedTripCount > 0
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentSavedTripCount > 0 ? Colors.redAccent : null,
                )),
          ],
        ),
        body: BlocListener<TripLocationBloc, TripLocationState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is TripLocationActionSucess && !_dialogShown) {
              setState(() {
                _dialogShown = true; // Mark dialog as shown
              });
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            text: 'Đã thay đổi',
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: widget.locationName,
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ' tại $changeSavedItemCount chuyến đi',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            final userId = (context.read<AppUserCubit>().state
                                    as AppUserLoggedIn)
                                .user
                                .id;
                            context.read<TripBloc>().add(GetSavedToTrips(
                                userId: userId,
                                id: widget.locationId,
                                type: 'location'));
                            displayModal(context, SavedToTripModal(
                              onTripsChanged: (List<Trip> selectedTrips,
                                  List<Trip> unselectedTrips) {
                                setState(() {
                                  changeSavedItemCount = selectedTrips.length +
                                      unselectedTrips.length;
                                });
                                for (var item in selectedTrips) {
                                  context
                                      .read<TripLocationBloc>()
                                      .add(InsertTripLocation(
                                        locationId: widget.locationId,
                                        tripId: item.id,
                                      ));
                                }

                                for (var item in unselectedTrips) {
                                  context
                                      .read<TripLocationBloc>()
                                      .add(DeleteTripLocation(
                                        locationId: widget.locationId,
                                        tripId: item.id,
                                      ));
                                }
                              },
                            ), null, false);
                          },
                          child: const Text('Thay đổi',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              NestedScrollView(
                  floatHeaderSlivers: true,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          // floating: true,
                          pinned: mapView,
                          leading: null,
                          automaticallyImplyLeading: false,
                          // snap: true,
                          scrolledUnderElevation: 0,
                          flexibleSpace: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 6),
                              child: Row(
                                children: List.generate(
                                  options.length, // Number of buttons
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Hero(
                                      tag: options[index],
                                      child: OutlinedButton(
                                        onPressed: () {
                                          if (index == 1) {
                                            if (latitude != null &&
                                                longitude != null) {
                                              log('latitude: $latitude, longitude: $longitude');
                                              Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      BlocProvider(
                                                    create: (context) =>
                                                        serviceLocator<
                                                            AttractionBloc>(),
                                                    child: AttractionListPage(
                                                      locationId:
                                                          widget.locationId,
                                                      locationName:
                                                          widget.locationName,
                                                      latitude: latitude!,
                                                      longitude: longitude!,
                                                    ),
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return child; // No transition for the rest of the page
                                                  },
                                                ),
                                              );
                                            } else {
                                              showSnackbar(context,
                                                  'Không có dữ liệu vị trí');
                                            }
                                          } else if (index == 2) {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    BlocProvider(
                                                  create: (context) =>
                                                      serviceLocator<
                                                          NearbyServicesCubit>(),
                                                  child: RestaurantListPage(
                                                    locationId:
                                                        widget.locationId,
                                                    locationName:
                                                        widget.locationName,
                                                    latitude: latitude!,
                                                    longitude: longitude!,
                                                  ),
                                                ),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return child; // No transition for the rest of the page
                                                },
                                              ),
                                            );
                                          } else if (index == 3) {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    BlocProvider(
                                                  create: (context) =>
                                                      serviceLocator<
                                                          NearbyServicesCubit>(),
                                                  child: HotelListPage(
                                                    locationName:
                                                        widget.locationName,
                                                    latitude: latitude!,
                                                    longitude: longitude!,
                                                  ),
                                                ),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return child; // No transition for the rest of the page
                                                },
                                              ),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              _selectedIndex == index
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize
                                              .min, // Ensures the button size matches the content
                                          children: [
                                            Icon(
                                              _convertIcon(
                                                  index), // Replace with the desired icon
                                              size: 20, // Adjust size as needed
                                              color: _selectedIndex == index
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                            ),
                                            const SizedBox(
                                                width:
                                                    8), // Spacing between the icon and text
                                            Text(
                                              options[index],
                                              style: TextStyle(
                                                color: _selectedIndex == index
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                  body: BlocConsumer<LocationBloc, LocationState>(
                    listener: (context, state) {
                      if (state is LocationFailure) {
                        showSnackbar(context, state.message);
                      }
                      if (state is LocationDetailsLoadedSuccess) {
                        setState(() {
                          latitude = state.location.latitude;
                          longitude = state.location.longitude;
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is LocationLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (state is LocationDetailsLoadedSuccess) {
                        final Location location = state.location;
                        final imgList = [...location.images, location.cover];

                        return BlocBuilder<LocationInfoCubit,
                            LocationInfoState>(
                          builder: (context, state2) {
                            if (state2 is LocationInfoLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state2 is LocationInfoFailure) {
                              return const Center(
                                child: Text('Không có dữ liệu'),
                              );
                            }
                            final locationInfo =
                                (state2 as LocationInfoLoaded).locationInfo;
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      SliderPagination(imgList: imgList),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 80),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Text(
                                            location.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 32),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                width: 40,
                                                height: 40,
                                                alignment: Alignment.center,
                                                child: const FaIcon(
                                                    FontAwesomeIcons
                                                        .locationDot,
                                                    size: 18),
                                              ),
                                              const SizedBox(width: 16),
                                              Flexible(
                                                child: Text(
                                                  location.address,
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (location.childLoc.isNotEmpty)
                                          SubLocationSection(
                                              locations: location.childLoc,
                                              locationName: location.name),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.0,
                                              bottom: 0,
                                              left: 20,
                                              right: 20),
                                          child: Divider(
                                            thickness: 1.5,
                                          ),
                                        ),
                                        if (locationInfo.tripbestModule != null)
                                          TripbestSection(
                                              tripbests:
                                                  locationInfo.tripbestModule!),
                                        AttractionsSection(
                                          attractions: locationInfo.attractions,
                                          locationId: location.id,
                                          locationName: location.name,
                                        ),
                                        RestaurantSection(
                                            restaurants:
                                                locationInfo.restaurants,
                                            locationName: location.name),
                                        HotelSection(
                                            hotels: locationInfo.hotels,
                                            locationName: location.name),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.0,
                                              bottom: 0,
                                              left: 20,
                                              right: 20),
                                          child: Divider(
                                            thickness: 1.5,
                                          ),
                                        ),
                                        if (locationInfo.comments != null)
                                          CommentSection(
                                              comments: locationInfo.comments!,
                                              locationName: location.name),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Không có dữ liệu'),
                      );
                    },
                  )),
              // Positioned(
              //   bottom: 70.0,
              //   right: 16.0,
              //   child: FloatingActionButton(
              //     onPressed: () {
              //       setState(() {
              //         mapView = !mapView;
              //       });
              //     },
              //     child: const Icon(Icons.map),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
