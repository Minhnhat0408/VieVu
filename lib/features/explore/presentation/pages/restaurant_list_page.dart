import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vn_travel_companion/core/constants/restaurant_filters.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_filter_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_open_time_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_price_range.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_service_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/restaurant/restaurant_small_card.dart';

class RestaurantListPage extends StatefulWidget {
  final String? locationName;
  final int? locationId;
  final double? latitude;
  final double? longitude;
  const RestaurantListPage({
    super.key,
    this.locationName,
    this.locationId,
    this.latitude,
    this.longitude,
  });

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final PagingController<int, Restaurant> _pagingController =
      PagingController(firstPageKey: 0);

  String? _selectedFilter;
  List<String> _selectedServices = [];
  List<String> _selectedOpenTime = [];
  int? _minPrice;
  int? _maxPrice;

  final int pageSize = 10;
  int totalRecordCount = 0;

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
    _pagingController.addPageRequestListener((pageKey) {
      context.read<NearbyServicesCubit>().getRestaurantsWithFilter(
            categoryId1: _selectedFilter != null
                ? restaurantFilterOptions[_selectedFilter]
                : null,
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

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName ?? "Nhà hàng"),
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
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
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
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
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
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
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
                                      options[index],
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
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 70),
                    sliver: PagedSliverList<int, Restaurant>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Restaurant>(
                        itemBuilder: (context, item, index) {
                          return RestaurantSmallCard(
                            restaurant: item,
                          );
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
              );
            },
          ),
        ),
        Positioned(
          bottom: 70.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const MapView(),
              //   ),
              // );
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
