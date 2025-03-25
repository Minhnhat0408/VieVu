import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/constants/restaurant_filters.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_filter_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_open_time_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_price_range.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_service_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_small_card.dart';

class RestaurantListPage extends StatefulWidget {
  final String locationName;
  final int locationId;
  final double? latitude;
  final double? longitude;
  const RestaurantListPage({
    super.key,
    required this.locationName,
    required this.locationId,
    this.latitude,
    this.longitude,
  });

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage>
    with TickerProviderStateMixin {
  final PagingController<int, Restaurant> _pagingController =
      PagingController(firstPageKey: 0);
  int activeIndex = 0;
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  String? _selectedFilter;
  List<String> _selectedServices = [];
  List<String> _selectedOpenTime = [];
  int? _minPrice;
  int? _maxPrice;
  bool mapView = false;
  final int pageSize = 10;
  int totalRecordCount = 0;
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  final options = [
    "Nhà hàng",
    "Ẩm thực",
    "Giờ mở cửa",
    "Giá",
    "Dịch vụ",
  ];
  IconData _convertIcon(int index) {
    switch (index) {
      case 0:
        return Icons.close;
      default:
        return Icons.arrow_drop_down_circle_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _pagingController.addPageRequestListener((pageKey) {
      context.read<NearbyServicesCubit>().getRestaurantsWithFilter(
            categoryId1: _selectedFilter != null
                ? restaurantFilterOptions[_selectedFilter]
                : null,
            userId: userId,
            serviceIds: _selectedServices
                .map((e) => restaurantServicesMap[e]!)
                .toList(),
            openTime: _selectedOpenTime
                .map((e) => restaurantTimeSlotsMap[e]!)
                .toList(),
            limit: pageSize,
            offset: (pageKey ~/ pageSize) + 1,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            lat: widget.latitude,
            lon: widget.longitude,
            locationId: widget.locationId,
          );
    });
  }

  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      zoom: 15,
      rotation: 0.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
    _animatedMapController.dispose();
  }

  String _convertFilterString(int index) {
    if (index == 1) {
      return _selectedFilter ?? "Ẩm thực";
    } else if (index == 3) {
      return (_minPrice != null || _maxPrice != null)
          ? "${NumberFormat('#,###').format(_minPrice)} - ${NumberFormat('#,###').format(_maxPrice)} vnd"
          : "Khoảng giá";
    } else {
      return options[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        centerTitle: true,
      ),
      body: Stack(children: [
        NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              leading: null,
              automaticallyImplyLeading: false,
              snap: true,
              scrolledUnderElevation: 0,
              flexibleSpace: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
                  child: Row(
                    children: List.generate(
                      options.length, // Number of buttons
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: index == 0
                            ? Hero(
                                tag: options[index],
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        options[index],
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _convertIcon(index),
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  if (options[index] == "Ẩm thực") {
                                    displayModal(
                                        context,
                                        RestaurantFilterModal(
                                          currentFilter: _selectedFilter,
                                          onFilterChanged: (newTravelType) {
                                            setState(() {
                                              _selectedFilter = newTravelType;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Giờ mở cửa") {
                                    displayModal(
                                        context,
                                        RestaurantOpenTimeModal(
                                          currentServices: _selectedOpenTime,
                                          onServicesChanged: (newServices) {
                                            setState(() {
                                              _selectedOpenTime = newServices;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Dịch vụ") {
                                    displayModal(
                                        context,
                                        RestaurantServiceModal(
                                          currentServices: _selectedServices,
                                          onServicesChanged: (newServices) {
                                            setState(() {
                                              _selectedServices = newServices;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        true);
                                  } else {
                                    displayModal(
                                        context,
                                        RestaurantPriceRange(
                                          maxPrice: _maxPrice,
                                          minPrice: _minPrice,
                                          onServicesChanged: (newServices) {
                                            setState(() {
                                              _maxPrice =
                                                  newServices[1].round();
                                              _minPrice =
                                                  newServices[0].round();
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        false);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: ((_selectedFilter != null &&
                                                options[index] == "Ẩm thực") ||
                                            (_selectedOpenTime.isNotEmpty &&
                                                options[index] ==
                                                    "Giờ mở cửa") ||
                                            ((_minPrice != null ||
                                                    _maxPrice != null) &&
                                                options[index] == "Giá") ||
                                            (_selectedServices.isNotEmpty &&
                                                options[index] == "Dịch vụ"))
                                        ? 2.0
                                        : 1.0, // Thicker border
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _convertFilterString(index),
                                      style: TextStyle(
                                        fontWeight: (_selectedFilter != null &&
                                                    options[index] ==
                                                        "Ẩm thực") ||
                                                (_selectedOpenTime.isNotEmpty &&
                                                    options[index] ==
                                                        "Giờ mở cửa") ||
                                                ((_minPrice != null ||
                                                        _maxPrice != null) &&
                                                    options[index] == "Giá") ||
                                                (_selectedServices.isNotEmpty &&
                                                    options[index] == "Dịch vụ")
                                            ? FontWeight.bold
                                            : FontWeight.normal, // Bold text
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _convertIcon(index),
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
          body: BlocConsumer<NearbyServicesCubit, NearbyServicesState>(
            listener: (context, state) {
              if (state is RestaurantLoadedSuccess) {
                totalRecordCount += state.restaurants.length;
                final next = totalRecordCount;
                final isLastPage = state.restaurants.length < pageSize;
                if (isLastPage) {
                  _pagingController.appendLastPage(state.restaurants);
                } else {
                  _pagingController.appendPage(state.restaurants, next);
                }
              }
            },
            builder: (context, state) {
              return LazyLoadIndexedStack(
                  index: mapView ? 0 : 1,
                  preloadIndexes: [
                    1
                  ],
                  autoDisposeIndexes: const [
                    0
                  ],
                  children: [
                    if (_pagingController.itemList != null)
                      Stack(
                        children: [
                          FlutterMap(
                            mapController: _animatedMapController.mapController,
                            options: MapOptions(
                                interactionOptions: const InteractionOptions(
                                  enableMultiFingerGestureRace: true,
                                ),
                                initialCenter: LatLng(
                                    widget.latitude!,
                                    widget
                                        .longitude!), // Center the map over London
                                initialCameraFit: CameraFit.coordinates(
                                    coordinates: _pagingController.itemList!
                                        .map(
                                          (attraction) => LatLng(
                                              attraction.latitude,
                                              attraction.longitude),
                                        )
                                        .toList()),
                                initialZoom: 13,
                                minZoom: 5),
                            children: [
                              TileLayer(
                                // Display map tiles from any source
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                                userAgentPackageName:
                                    'com.example.vn_travel_companion',
                                // And many more recommended properties!
                              ),
                              MarkerLayer(markers: [
                                Marker(
                                  width: 70,
                                  height: 70,
                                  point: LatLng(
                                      widget.latitude!, widget.longitude!),
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
                                    ..._pagingController.itemList!
                                        .asMap()
                                        .entries
                                        .map((item) {
                                      final attraction = item.value;

                                      return Marker(
                                        width: activeIndex == attraction.id
                                            ? 80
                                            : 60,
                                        height: activeIndex == attraction.id
                                            ? 80
                                            : 60,
                                        point: LatLng(attraction.latitude,
                                            attraction.longitude),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              buttonCarouselController
                                                  .animateToPage(item.key,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut);
                                              activeIndex = attraction.id;
                                            });
                                          },
                                          child: Container(
                                            width: activeIndex == attraction.id
                                                ? 80
                                                : 60,
                                            height: activeIndex == attraction.id
                                                ? 80
                                                : 60,
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      activeIndex ==
                                                              attraction.id
                                                          ? 10
                                                          : 30),
                                              image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        attraction.cover),
                                                fit: BoxFit.cover,
                                              ),
                                              border: Border.all(
                                                color: Colors.orange,
                                                width:
                                                    activeIndex == attraction.id
                                                        ? 5
                                                        : 3,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.orange),
                                      child: Center(
                                        child: Text(
                                          markers.length.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
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
                            itemCount: _pagingController.itemList!.length,
                            carouselController: buttonCarouselController,
                            itemBuilder: (context, index, realIndex) {
                              return RepaintBoundary(
                                child: RestaurantSmallCard(
                                  restaurant:
                                      _pagingController.itemList![index],
                                  slider: true,
                                  locationName: widget.locationName,
                                  locationId: widget.locationId,
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 130,
                              initialPage: 0,
                              reverse: false,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) => setState(() {
                                activeIndex =
                                    _pagingController.itemList![index].id;

                                if (index ==
                                    _pagingController.itemList!.length - 1) {
                                  if ((index + 1) % pageSize == 0) {
                                    final nextPageKey =
                                        (_pagingController.itemList!.length ~/
                                                pageSize) +
                                            1;
                                    final userId = (context
                                            .read<AppUserCubit>()
                                            .state as AppUserLoggedIn)
                                        .user
                                        .id;
                                    context
                                        .read<NearbyServicesCubit>()
                                        .getRestaurantsWithFilter(
                                          userId: userId,
                                          categoryId1: _selectedFilter != null
                                              ? restaurantFilterOptions[
                                                  _selectedFilter]
                                              : null,
                                          serviceIds: _selectedServices
                                              .map((e) =>
                                                  restaurantServicesMap[e]!)
                                              .toList(),
                                          openTime: _selectedOpenTime
                                              .map((e) =>
                                                  restaurantTimeSlotsMap[e]!)
                                              .toList(),
                                          limit: pageSize,
                                          offset: nextPageKey,
                                          minPrice: _minPrice,
                                          maxPrice: _maxPrice,
                                          lat: widget.latitude,
                                          lon: widget.longitude,
                                          locationId: widget.locationId,
                                        );
                                  }
                                }
                                _animateMapTo(LatLng(
                                    _pagingController.itemList![index].latitude,
                                    _pagingController
                                        .itemList![index].longitude));
                              }),
                            ),
                          ),
                        ],
                      ),
                    if (_pagingController.itemList == null)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 70),
                          sliver: PagedSliverList<int, Restaurant>(
                            pagingController: _pagingController,
                            builderDelegate:
                                PagedChildBuilderDelegate<Restaurant>(
                              itemBuilder: (context, item, index) {
                                return RestaurantSmallCard(
                                  restaurant: item,
                                  locationName: widget.locationName,
                                  locationId: widget.locationId,
                                );
                              },
                              firstPageProgressIndicatorBuilder: (_) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                              newPageProgressIndicatorBuilder: (_) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                              noItemsFoundIndicatorBuilder: (_) => const Center(
                                  child: Text('Không có điểm du lịch nào.')),
                              newPageErrorIndicatorBuilder: (context) => Center(
                                child: TextButton(
                                  onPressed: () => _pagingController
                                      .retryLastFailedRequest(),
                                  child: const Text('Thử lại'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]);
            },
          ),
        ),
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
      ]),
    );
  }
}
