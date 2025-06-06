import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:latlong2/latlong.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:vievu/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/attraction_med_card.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/filter_all_attraction_modal.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/parent_travel_type_modal.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/rating_modal.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/sort_type_modal.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';

class AttractionListPage extends StatefulWidget {
  final String? locationName;
  final int? locationId;
  final double? latitude;
  final double? longitude;

  const AttractionListPage({
    super.key,
    this.locationName,
    this.locationId,
    this.latitude,
    this.longitude,
  });

  @override
  State<AttractionListPage> createState() => _AttractionListPageState();
}

class _AttractionListPageState extends State<AttractionListPage>
    with TickerProviderStateMixin {
  final PagingController<int, Attraction> _pagingController =
      PagingController(firstPageKey: 0);
  String _sortType = "hot_score";
  TravelType? _parentTravelType;
  List<TravelType> _travelTypes = [];
  final int pageSize = 10;
  int totalRecordCount = 0;
  bool mapView = false;
  int? _currentBudget;
  // final MapController _mapController = MapController();
  int activeIndex = 0;
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  int? _currentRating;
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true); // Default to false);
  final options = [
    "Địa điểm du lịch",
    "Loại hình du lịch",
    "Đánh giá",
    "Bộ lọc",
  ];
  IconData _convertIcon(int index) {
    switch (index) {
      case 0:
        return Icons.close;

      case 3:
        return Icons.tune;
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
      if (widget.locationId != null) {
        context.read<AttractionBloc>().add(
              GetAttractionsWithFilter(
                  locationId: widget.locationId,
                  limit: pageSize - 1,
                  offset: pageKey,
                  userId: userId,
                  categoryId1: _parentTravelType?.id,
                  sortType: _sortType,
                  categoryId2: _travelTypes.isNotEmpty
                      ? _travelTypes.map((e) => e.id).toList()
                      : null,
                  rating: _currentRating,
                  budget: _currentBudget,
                  topRanked: false),
            );
      } else {
        context.read<AttractionBloc>().add(
              GetAttractionsWithFilter(
                  lat: widget.latitude,
                  lon: widget.longitude,
                  userId: userId,
                  proximity: 30,
                  limit: pageSize - 1,
                  offset: pageKey,
                  categoryId1: _parentTravelType?.id,
                  sortType: _sortType,
                  categoryId2: _travelTypes.isNotEmpty
                      ? _travelTypes.map((e) => e.id).toList()
                      : null,
                  rating: _currentRating,
                  budget: _currentBudget,
                  topRanked: false),
            );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animatedMapController.dispose();

    _pagingController.dispose();
  }

  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,

      rotation: 0.0,
    );
  }

  String _convertFilterString(int index) {
    if (index == 1) {
      return _parentTravelType != null
          ? _parentTravelType!.name
          : options[index];
    } else if (index == 2) {
      return _currentRating != null
          ? "Đánh giá $_currentRating sao"
          : options[index];
    } else {
      return options[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    log(widget.locationId.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName ?? 'Danh sách điểm du lịch'),
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
                                  if (index == 1) {
                                    displayModal(
                                        context,
                                        ParentTravelTypeModal(
                                          currentTravelType: _parentTravelType,
                                          onTravelTypeChanged: (newTravelType) {
                                            setState(() {
                                              _parentTravelType = newTravelType;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        600,
                                        false);
                                  } else if (index == 2) {
                                    displayModal(
                                        context,
                                        RatingModal(
                                          currentRating: _currentRating,
                                          onRatingChanged: (newRating) {
                                            setState(() {
                                              _currentRating = newRating;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        false);
                                  } else {
                                    displayModal(
                                        context,
                                        FilterAllAtrractionModal(
                                          currentSortType: _sortType,
                                          currentParentTravelType:
                                              _parentTravelType,
                                          currentRating: _currentRating,
                                          currentTravelTypes: _travelTypes,
                                          currentBudget: _currentBudget,
                                          onFilterChanged: (newSortType,
                                              newParentTravelType,
                                              newTravelTypes,
                                              newRating,
                                              newBudget) {
                                            setState(() {
                                              _sortType = newSortType;
                                              _parentTravelType =
                                                  newParentTravelType;
                                              _travelTypes = newTravelTypes;
                                              _currentRating = newRating;
                                              _currentBudget = newBudget;
                                            });
                                            totalRecordCount = 0;
                                            _pagingController.refresh();
                                          },
                                        ),
                                        null,
                                        true);
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
                                    width: ((_parentTravelType != null &&
                                                (index == 1 || index == 3)) ||
                                            (_currentRating != null &&
                                                (index == 2 || index == 3)))
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
                                        fontWeight: ((_parentTravelType !=
                                                        null &&
                                                    (index == 1 ||
                                                        index == 3)) ||
                                                (_currentRating != null &&
                                                    (index == 2 || index == 3)))
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
          body: BlocConsumer<AttractionBloc, AttractionState>(
            listener: (context, state) {
              if (state is AttractionFailure) {
                log(state.message.toString());
              }
              if (state is AttractionsLoadedSuccess) {
                totalRecordCount += state.attractions.length;

                final next = totalRecordCount;
                final isLastPage = state.attractions.length < pageSize;
                if (isLastPage) {
                  _pagingController.appendLastPage(state.attractions);
                } else {
                  _pagingController.appendPage(state.attractions, next);
                }
              }
            },
            builder: (context, state) {
              return LazyLoadIndexedStack(
                index: mapView ? 0 : 1,
                preloadIndexes: [1],
                autoDisposeIndexes: const [0],
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

                              initialZoom: 11,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
                                        borderRadius: BorderRadius.circular(20),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
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
                              child: AttractionMedCard(
                                attraction: _pagingController.itemList![index],
                                slider: true,
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
                                  final pageKey = totalRecordCount;
                                  final userId = (context
                                          .read<AppUserCubit>()
                                          .state as AppUserLoggedIn)
                                      .user
                                      .id;
                                  if (widget.locationId != null) {
                                    context.read<AttractionBloc>().add(
                                          GetAttractionsWithFilter(
                                              locationId: widget.locationId,
                                              limit: pageSize - 1,
                                              offset: pageKey,
                                              userId: userId,
                                              categoryId1:
                                                  _parentTravelType?.id,
                                              sortType: _sortType,
                                              categoryId2:
                                                  _travelTypes.isNotEmpty
                                                      ? _travelTypes
                                                          .map((e) => e.id)
                                                          .toList()
                                                      : null,
                                              rating: _currentRating,
                                              budget: _currentBudget,
                                              topRanked: false),
                                        );
                                  } else {
                                    context.read<AttractionBloc>().add(
                                          GetAttractionsWithFilter(
                                              lat: widget.latitude,
                                              lon: widget.longitude,
                                              userId: userId,
                                              proximity: 30,
                                              limit: pageSize - 1,
                                              offset: pageKey,
                                              categoryId1:
                                                  _parentTravelType?.id,
                                              sortType: _sortType,
                                              categoryId2:
                                                  _travelTypes.isNotEmpty
                                                      ? _travelTypes
                                                          .map((e) => e.id)
                                                          .toList()
                                                      : null,
                                              rating: _currentRating,
                                              budget: _currentBudget,
                                              topRanked: false),
                                        );
                                  }
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
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    displayModal(
                                        context,
                                        SortModal(
                                          currentSortType: _sortType,
                                          onSortChanged: (newSortType) {
                                            setState(() {
                                              _sortType = newSortType;
                                              _pagingController
                                                  .refresh(); // Refresh the list with the new sort type
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        _sortType == "hot_score"
                                            ? "Phổ biến nhất"
                                            : "Đánh giá cao nhất",
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PagedSliverList<int, Attraction>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Attraction>(
                          itemBuilder: (context, item, index) {
                            return AttractionMedCard(
                              attraction: item,
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
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 70), // Add vertical spacing
                      ),
                    ],
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
