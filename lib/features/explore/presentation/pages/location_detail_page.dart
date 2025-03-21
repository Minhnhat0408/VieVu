import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/calculate_distance.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/hotel_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/restaurant_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/attraction_med_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_small_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_small_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
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

class LocationDetailMainState extends State<LocationDetailMain>
    with TickerProviderStateMixin {
  final int _selectedIndex = 0;
  int activeIndex = 0;
  bool reversedTrans = false;
  bool mapView = false;
  double? latitude;
  double? longitude;
  int changeSavedItemCount = 0;
  int currentSavedTripCount = 0;
  List<dynamic> allServices = [];
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      zoom: 15,
      rotation: 0.0,
    );
  }

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<TripBloc>().add(GetSavedToTrips(
          userId: userId,
          id: widget.locationId,
        ));
    context
        .read<LocationBloc>()
        .add(GetLocation(locationId: widget.locationId));
    context.read<LocationInfoCubit>().fetchLocationInfo(
        locationId: widget.locationId,
        userId: userId,
        locationName: widget.locationName);
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
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
    return Scaffold(
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
          BlocListener<TripBloc, TripState>(
            listener: (context, state) {
              if (state is SavedToTripLoadedSuccess) {
                currentSavedTripCount =
                    state.trips.where((trip) => trip.isSaved).length;
              }
            },
            child: IconButton(
                onPressed: () => _showSaveModal(context),
                icon: Icon(
                  currentSavedTripCount > 0
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentSavedTripCount > 0 ? Colors.redAccent : null,
                )),
          ),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      leading: null,
                      automaticallyImplyLeading: false,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Hero(
                                  tag: options[index],
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (index == 1) {
                                        if (latitude != null &&
                                            longitude != null) {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  BlocProvider(
                                                create: (context) =>
                                                    serviceLocator<
                                                        AttractionBloc>(),
                                                child: AttractionListPage(
                                                  locationId: widget.locationId,
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
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                BlocProvider(
                                              create: (context) =>
                                                  serviceLocator<
                                                      NearbyServicesCubit>(),
                                              child: RestaurantListPage(
                                                locationId: widget.locationId,
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
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                BlocProvider(
                                              create: (context) =>
                                                  serviceLocator<
                                                      NearbyServicesCubit>(),
                                              child: HotelListPage(
                                                locationName:
                                                    widget.locationName,
                                                locationId: widget.locationId,
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
                                      backgroundColor: _selectedIndex == index
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

                    return BlocBuilder<LocationInfoCubit, LocationInfoState>(
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
                        allServices = [
                          ...locationInfo.attractions,
                          ...locationInfo.restaurants,
                          ...locationInfo.hotels,
                        ];
                        allServices.sort((a, b) {
                          double distanceA = calculateDistance(
                            a.latitude,
                            a.longitude,
                            state.location.latitude,
                            state.location.longitude,
                          );
                          double distanceB = calculateDistance(
                            b.latitude,
                            b.longitude,
                            state.location.latitude,
                            state.location.longitude,
                          );
                          return distanceA.compareTo(
                              distanceB); // Sort by ascending distance
                        });
                        return LazyLoadIndexedStack(
                            index: mapView ? 0 : 1,
                            children: [
                              _buildMapView(location, state),
                              _buildDetailsView(
                                  location, locationInfo, imgList),
                            ]);
                      },
                    );
                  }
                  return const Center(
                    child: Text('Không có dữ liệu'),
                  );
                },
              )),
          Positioned(
            bottom: 70.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  mapView = !mapView;
                });
              },
              child: const Icon(Icons.map),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(Location location, LocationDetailsLoadedSuccess state) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
              ),
              initialCenter: LatLng(state.location.latitude,
                  state.location.longitude), // Center the map over London
              initialCameraFit: CameraFit.coordinates(
                  coordinates: allServices
                      .map(
                        (e) => LatLng(e.latitude, e.longitude),
                      )
                      .toList()),
              initialZoom: 11,
              minZoom: 5),
          children: [
            TileLayer(
              // Display map tiles from any source
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

              userAgentPackageName: 'com.example.vn_travel_companion',
              // And many more recommended properties!
            ),
            MarkerLayer(markers: [
              Marker(
                width: 70,
                height: 70,
                point:
                    LatLng(state.location.latitude, state.location.longitude),
                //circle avatar with border
                child: Image.asset(
                  'assets/icons/main2.png',
                  width: 70,
                  height: 70,
                ),
              ),
            ]),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(60, 60),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                maxZoom: 15,
                markers: [
                  ...allServices.asMap().entries.map((item) {
                    final attraction = item.value;

                    return Marker(
                      width: activeIndex == attraction.id ? 80 : 60,
                      height: activeIndex == attraction.id ? 80 : 60,
                      point: LatLng(attraction.latitude, attraction.longitude),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            buttonCarouselController.animateToPage(item.key,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                            activeIndex = attraction.id;
                          });
                        },
                        child: Container(
                          width: activeIndex == attraction.id ? 80 : 60,
                          height: activeIndex == attraction.id ? 80 : 60,
                          decoration: BoxDecoration(
                            color: attraction is Attraction
                                ? Theme.of(context).colorScheme.primary
                                : attraction is Restaurant
                                    ? Colors.orangeAccent
                                    : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(
                                activeIndex == attraction.id ? 10 : 30),
                            image: DecorationImage(
                              image:
                                  CachedNetworkImageProvider(attraction.cover),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: attraction is Attraction
                                  ? Theme.of(context).colorScheme.primary
                                  : attraction is Restaurant
                                      ? Colors.orangeAccent
                                      : Colors.blueAccent,
                              width: activeIndex == attraction.id ? 5 : 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.primary),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 70,
          left: 16.0,
          child: FloatingActionButton(
            heroTag: 'rotate',
            onPressed: () {
              // Rotate the map by 45 degrees
              _animatedMapController.animatedRotateTo(0);
            },
            child: const Icon(Icons.rotate_right),
          ),
        ),
        CarouselSlider.builder(
          itemCount: allServices.length,
          carouselController: buttonCarouselController,
          itemBuilder: (context, index, realIndex) {
            if (allServices[index] is Attraction) {
              final attraction = allServices[index] as Attraction;
              return RepaintBoundary(
                child: AttractionMedCard(
                  attraction: attraction,
                  slider: true,
                ),
              );
            } else if (allServices[index] is Restaurant) {
              final restaurant = allServices[index] as Restaurant;
              return RepaintBoundary(
                child: RestaurantSmallCard(
                  restaurant: restaurant,
                  locationId: widget.locationId,
                  locationName: widget.locationName,
                  slider: true,
                ),
              );
            } else {
              final hotel = allServices[index] as Hotel;
              return RepaintBoundary(
                child: HotelSmallCard(
                  hotel: hotel,
                  locationId: widget.locationId,
                  locationName: widget.locationName,
                  slider: true,
                ),
              );
            }
          },
          options: CarouselOptions(
            height: 130,
            initialPage: 0,
            reverse: false,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) => setState(() {
              activeIndex = allServices[index].id;

              _animateMapTo(LatLng(
                  allServices[index].latitude, allServices[index].longitude));
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView(Location location, GenericLocationInfo locationInfo,
      List<String> imgList) {
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
            padding: const EdgeInsets.only(top: 20, bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    location.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
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
                        child: Text(
                          location.address,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      top: 20.0, bottom: 0, left: 20, right: 20),
                  child: Divider(
                    thickness: 1.5,
                  ),
                ),
                if (locationInfo.tripbestModule != null)
                  TripbestSection(tripbests: locationInfo.tripbestModule!),
                AttractionsSection(
                  attractions: locationInfo.attractions,
                ),
                RestaurantSection(
                  restaurants: locationInfo.restaurants,
                ),
                HotelSection(
                  hotels: locationInfo.hotels,
                ),
                const Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, bottom: 0, left: 20, right: 20),
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
  }

  void _showSaveModal(BuildContext context) {
    // Add modal logic
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<TripBloc>().add(GetSavedToTrips(
          userId: userId,
          id: widget.locationId,
        ));

    final locationDetails =
        (context.read<LocationBloc>().state as LocationDetailsLoadedSuccess)
            .location;
    displayModal(context, SavedToTripModal(
      onTripsChanged: (List<Trip> selectedTrips, List<Trip> unselectedTrips) {
        setState(() {
          changeSavedItemCount = selectedTrips.length + unselectedTrips.length;

          currentSavedTripCount = currentSavedTripCount +
              selectedTrips.length -
              unselectedTrips.length;
        });

        for (var item in selectedTrips) {
          context.read<SavedServiceBloc>().add(InsertSavedService(
                tripId: item.id,
                linkId: widget.locationId,
                cover: locationDetails.cover,
                name: widget.locationName,
                locationName: widget.locationName,
                rating: 0,
                ratingCount: 0,
                typeId: 0,
                latitude: locationDetails.latitude,
                longitude: locationDetails.longitude,
              ));
        }

        for (var item in unselectedTrips) {
          context.read<SavedServiceBloc>().add(
              DeleteSavedService(linkId: widget.locationId, tripId: item.id));
        }
      },
    ), null, false);
  }
}
