import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/services/service_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/services/service_big_card.dart';

class AllNearbyServicePage extends StatefulWidget {
  const AllNearbyServicePage({super.key});

  @override
  State<AllNearbyServicePage> createState() => _AllNearbyServicePageState();
}

class _AllNearbyServicePageState extends State<AllNearbyServicePage>
    with TickerProviderStateMixin {
  List<double>? userPos;
  LocationPermission locationPermission = LocationPermission.denied;
  List<Service> services = [];
  List<Service> attractions = [];
  List<Service> restaurants = [];
  List<Service> hotels = [];
  int activeIndex = 0;
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  @override
  void initState() {
    super.initState();
    _updateAndStoreCurrentLocation();
  }

  void _fetchNearbyAttractions() {
    if (userPos != null) {
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<NearbyServicesCubit>().getNearbyServices(
          limit: 10,
          offset: 1,
          userId: userId,
          filterType: 'nearby10KM',
          latitude: userPos![0],
          longitude: userPos![1]);
      context
          .read<LocationInfoCubit>()
          .convertGeoLocationToAddress(userPos![0], userPos![1]);
    } else {
      // log('User position is null. Skipping fetching attractions.');
    }
  }

  // bool _hasLocationPermission() {
  //   return locationPermission == LocationPermission.whileInUse ||
  //       locationPermission == LocationPermission.always;
  // }

  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      zoom: 15,
      rotation: 0.0,
    );
  }

  Future<void> _updateAndStoreCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      // log('Current Position: ${position.latitude}, ${position.longitude}');

      setState(() {
        userPos = [20.9907609, 105.8159886];
      });

      // Save position to Hive
      final locationBox = Hive.box('locationBox');
      locationBox.put('latitude', position.latitude);
      locationBox.put('longitude', position.longitude);
      _fetchNearbyAttractions();
    } catch (e) {
      showSnackbar(context, 'Không thể xác định vị trí của bạn.', 'error');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animatedMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gần bạn'),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: BlocConsumer<NearbyServicesCubit, NearbyServicesState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AllNearbyServicesLoadedSuccess) {
            final servicesTmp = state.services;
            final restaurants = servicesTmp['restaurants']!;
            final attractions = servicesTmp['attractions']!;
            final hotels = servicesTmp['hotels']!;

            // sort by distance and add to services list
            setState(() {
              this.attractions = attractions;
              this.restaurants = restaurants;
              this.hotels = hotels;
              services = [...restaurants, ...attractions, ...hotels];
              services.sort((a, b) => a.distance!.compareTo(b.distance!));
            });
          }
        },
        builder: (context, state) {
          if (state is NearbyServicesLoading ||
              state is NearbyServicesInitial) {
            log('loading');
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return BlocBuilder<LocationInfoCubit, LocationInfoState>(
            builder: (context, state) {
              return SlidingUpPanel(
                defaultPanelState: PanelState.OPEN,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                color: Theme.of(context).colorScheme.surface,
                panelBuilder: (scrollController) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      // Add a top control for dragging
                      Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      const SizedBox(
                          height:
                              12), // Spacing between drag handle and content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              // Panel content here
                              const SizedBox(height: 20),
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const FaIcon(
                                          FontAwesomeIcons.locationDot,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Text(
                                        state is LocationInfoAddressLoaded
                                            ? state.address
                                            : 'Đang tải...',
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0, bottom: 0, left: 20, right: 20),
                                child: Divider(thickness: 1.5),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Địa điểm du lịch',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Những địa điểm tham quan, hoạt động khám phá và trải nghiệm đặc trưng gần bạn',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 390,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: attractions.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0 ? 20.0 : 4.0,
                                        right: index == attractions.length - 1
                                            ? 20.0
                                            : 4.0,
                                      ),
                                      child: ServiceBigCard(
                                          service: attractions[index],
                                          type: 'Địa điểm du lịch'),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nhà hàng',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Nhà hàng, quán ăn, quán cà phê và quán bar xuất sắc gần bạn',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 390,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: restaurants.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0 ? 20.0 : 4.0,
                                        right: index == restaurants.length - 1
                                            ? 20.0
                                            : 4.0,
                                      ),
                                      child: ServiceBigCard(
                                          service: restaurants[index],
                                          type: 'Nhà hàng'),
                                    );
                                  },
                                ),
                              ),
                              if (hotels.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 20, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khách sạn',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Sự giao hòa giữa nét quyến rũ, tính biểu tượng và vẻ đẹp hiện đại ở gần bạn',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hotels.isNotEmpty)
                                SizedBox(
                                  height: 390,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: hotels.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: index == 0 ? 20.0 : 4.0,
                                          right: index == hotels.length - 1
                                              ? 20.0
                                              : 4.0,
                                        ),
                                        child: ServiceBigCard(
                                            service: hotels[index],
                                            type: 'Khách sạn'),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                parallaxEnabled: true,
                parallaxOffset: 0.7,
                body: Stack(
                  children: [
                    if (userPos != null)
                      FlutterMap(
                        mapController: _animatedMapController.mapController,
                        options: MapOptions(
                            initialCenter:
                                LatLng(userPos![0] - 0.005, userPos![1]),
                            minZoom: 3),
                        children: [
                          TileLayer(
                            // Display map tiles from any source
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                            userAgentPackageName:
                                'com.example.vn_travel_companion',
                            // And many more recommended properties!
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              width: 70,
                              height: 70,
                              point: LatLng(userPos![0], userPos![1]),
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
                                ...services.asMap().entries.map((item) {
                                  final ser = item.value;

                                  return Marker(
                                    width: activeIndex == ser.id ? 80 : 60,
                                    height: activeIndex == ser.id ? 80 : 60,
                                    point: LatLng(ser.latitude, ser.longitude),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          buttonCarouselController
                                              .animateToPage(item.key,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut);
                                          activeIndex = ser.id;
                                        });
                                      },
                                      child: Container(
                                        width: activeIndex == ser.id ? 80 : 60,
                                        height: activeIndex == ser.id ? 80 : 60,
                                        decoration: BoxDecoration(
                                          color: ser.typeId == 1
                                              ? Colors.orange
                                              : ser.typeId == 2
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.blueAccent,
                                          borderRadius: BorderRadius.circular(
                                              activeIndex == ser.id ? 10 : 30),
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                ser.cover),
                                            fit: BoxFit.cover,
                                          ),
                                          border: Border.all(
                                            color: ser.typeId == 1
                                                ? Colors.orange
                                                : ser.typeId == 2
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.blueAccent,
                                            width:
                                                activeIndex == ser.id ? 5 : 3,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  child: Center(
                                    child: Text(
                                      markers.length.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    Positioned(
                      bottom: 220,
                      left: 20.0,
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
                      itemCount: services.length,
                      carouselController: buttonCarouselController,
                      itemBuilder: (context, index, realIndex) {
                        return ServiceCard(
                            service: services[index],
                            slider: true,
                            type: services[index].typeId == 1
                                ? "Nhà hàng"
                                : services[index].typeId == 2
                                    ? "Địa điểm du lịch"
                                    : "Khách sạn");
                      },
                      options: CarouselOptions(
                        height: 130,
                        initialPage: 0,
                        viewportFraction: 0.8,
                        reverse: false,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) => setState(() {
                          activeIndex = services[index].id;

                          _animateMapTo(LatLng(services[index].latitude,
                              services[index].longitude));
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
