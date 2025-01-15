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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_price_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_room_info_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_small_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_star_modal.dart';

class HotelListPage extends StatefulWidget {
  final String locationName;
  final double? latitude;
  final double? longitude;
  const HotelListPage({
    super.key,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage>
    with TickerProviderStateMixin {
  final PagingController<int, Hotel> _pagingController =
      PagingController(firstPageKey: 0);
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  int? _star;
  int _roomQuantity = 1;
  int _adultCount = 2;
  int _childCount = 0;
  int? _minPrice;
  int? _maxPrice;
  int activeIndex = 0;
  bool mapView = false;
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  final int pageSize = 10;
  int totalRecordCount = 0;
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 1)),
  );
  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      zoom: 15,
      rotation: 0.0,
    );
  }

  String _convertFilterString(int index) {
    if (index == 3) {
      return _star != null ? "Khách sạn $_star sao" : options[index];
    } else if (index == 2) {
      return (_minPrice != null || _maxPrice != null)
          ? "${NumberFormat('#,###').format(_minPrice)} - ${NumberFormat('#,###').format(_maxPrice)} vnd"
          : "Khoảng giá";
    } else {
      return options[index];
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: selectedDateRange,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      totalRecordCount = 0;
      _pagingController.refresh();
    }
  }

  final options = ["Khách sạn", "Ngày", "Khoảng giá", "Sao", "Tùy chọn phòng"];
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
    _pagingController.addPageRequestListener((pageKey) {
      context.read<NearbyServicesCubit>().getHotelsWithFilter(
            checkInDate: selectedDateRange.start,
            checkOutDate: selectedDateRange.end,
            roomQuantity: _roomQuantity,
            adultCount: _adultCount,
            childCount: _childCount,
            star: _star,
            limit: pageSize,
            offset: (pageKey ~/ pageSize) + 1,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            locationName: widget.locationName,
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
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
                                  if (options[index] == "Khoảng giá") {
                                    displayModal(
                                        context,
                                        HotelPriceModal(
                                          maxPrice: _maxPrice,
                                          minPrice: _minPrice,
                                          onServicesChanged: (newServices) {
                                            setState(() {
                                              _maxPrice =
                                                  newServices[1].round();
                                              _minPrice =
                                                  newServices[0].round();
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Sao") {
                                    displayModal(
                                        context,
                                        HotelStarModal(
                                          currentRating: _star,
                                          onRatingChanged: (newRating) {
                                            setState(() {
                                              _star = newRating;
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Ngày") {
                                    _selectDateRange(context);
                                  } else {
                                    displayModal(
                                        context,
                                        HotelRoomInfoModal(
                                          roomQuantity: _roomQuantity,
                                          adultCount: _adultCount,
                                          childCount: _childCount,
                                          onRoomInfoChanged: (newRoomInfo) {
                                            setState(() {
                                              _roomQuantity = newRoomInfo[0];
                                              _adultCount = newRoomInfo[1];
                                              _childCount = newRoomInfo[2];
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
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
                                    width: (options[index] == "Khoảng giá" &&
                                                (_minPrice != null ||
                                                    _maxPrice != null)) ||
                                            (options[index] == "Sao" &&
                                                _star != null) ||
                                            (options[index] == "Ngày" &&
                                                index == 1) ||
                                            (options[index] ==
                                                    "Tùy chọn phòng" &&
                                                (_roomQuantity != 1 ||
                                                    _adultCount != 2 ||
                                                    _childCount != 0))
                                        ? 2.0
                                        : 1.0, // Thicker border
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      index != 1
                                          ? _convertFilterString(index)
                                          : "${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)}-${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}",
                                      style: TextStyle(
                                        fontWeight: (options[index] ==
                                                        "Khoảng giá" &&
                                                    (_minPrice != null ||
                                                        _maxPrice != null)) ||
                                                (options[index] == "Sao" &&
                                                    _star != null) ||
                                                (options[index] == "Ngày" &&
                                                    index == 1) ||
                                                (options[index] ==
                                                        "Tùy chọn phòng" &&
                                                    (_roomQuantity != 1 ||
                                                        _adultCount != 2 ||
                                                        _childCount != 0))
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
              if (state is HotelLoadedSuccess) {
                totalRecordCount += state.hotels.length;
                final next = totalRecordCount;
                final isLastPage = state.hotels.length < pageSize;
                if (isLastPage) {
                  _pagingController.appendLastPage(state.hotels);
                } else {
                  _pagingController.appendPage(state.hotels, next);
                }
              }
            },
            builder: (context, state) {
              return IndexedStack(index: mapView ? 0 : 1, children: [
                if (_pagingController.itemList != null)
                  Stack(
                    children: [
                      FlutterMap(
                        mapController: _animatedMapController.mapController,
                        options: MapOptions(
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
                            minZoom: 5),
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
                              point:
                                  LatLng(widget.latitude!, widget.longitude!),
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
                                    width:
                                        activeIndex == attraction.id ? 80 : 60,
                                    height:
                                        activeIndex == attraction.id ? 80 : 60,
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
                                          color: Colors.blueAccent,
                                          borderRadius: BorderRadius.circular(
                                              activeIndex == attraction.id
                                                  ? 10
                                                  : 30),
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                attraction.cover),
                                            fit: BoxFit.cover,
                                          ),
                                          border: Border.all(
                                            color: Colors.blueAccent,
                                            width: activeIndex == attraction.id
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
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blueAccent),
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
                          return HotelSmallCard(
                            hotel: _pagingController.itemList![index],
                            slider: true,
                          );
                        },
                        options: CarouselOptions(
                          height: 130,
                          initialPage: 0,
                          reverse: false,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) => setState(() {
                            activeIndex = _pagingController.itemList![index].id;

                            if (index ==
                                _pagingController.itemList!.length - 1) {
                              if ((index + 1) % pageSize == 0) {
                                final nextPageKey =
                                    (totalRecordCount ~/ pageSize) + 1;
                                context
                                    .read<NearbyServicesCubit>()
                                    .getHotelsWithFilter(
                                      checkInDate: selectedDateRange.start,
                                      checkOutDate: selectedDateRange.end,
                                      roomQuantity: _roomQuantity,
                                      adultCount: _adultCount,
                                      childCount: _childCount,
                                      star: _star,
                                      limit: pageSize,
                                      offset: nextPageKey,
                                      minPrice: _minPrice,
                                      maxPrice: _maxPrice,
                                      locationName: widget.locationName,
                                    );
                              }
                            }
                            _animateMapTo(LatLng(
                                _pagingController.itemList![index].latitude,
                                _pagingController.itemList![index].longitude));
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
                      sliver: PagedSliverList<int, Hotel>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Hotel>(
                          itemBuilder: (context, item, index) {
                            return HotelSmallCard(hotel: item);
                          },
                          firstPageProgressIndicatorBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          newPageProgressIndicatorBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          noItemsFoundIndicatorBuilder: (_) => const Center(
                              child: Text('Không có điểm du lịch nào.')),
                          newPageErrorIndicatorBuilder: (context) => Center(
                            child: TextButton(
                              onPressed: () =>
                                  _pagingController.retryLastFailedRequest(),
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

void displayModal(
    BuildContext context, Widget child, double? height, bool expand) {
  showBarModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    useRootNavigator: true,
    enableDrag: true,
    topControl: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    expand: expand,
    builder: (context) =>
        height != null ? SizedBox(height: height, child: child) : child,
  );
}
