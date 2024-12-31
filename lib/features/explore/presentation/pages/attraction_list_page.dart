import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/attraction_med_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/filter_all_attraction_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/parent_travel_type_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/rating_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/sort_type_modal.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';

class AttractionListPage extends StatefulWidget {
  final String locationName;
  final int locationId;
  const AttractionListPage({
    super.key,
    required this.locationName,
    required this.locationId,
  });

  @override
  State<AttractionListPage> createState() => _AttractionListPageState();
}

class _AttractionListPageState extends State<AttractionListPage> {
  final PagingController<int, Attraction> _pagingController =
      PagingController(firstPageKey: 0);
  String _sortType = "hot_score";
  TravelType? _parentTravelType;
  List<TravelType> _travelTypes = [];
  final int pageSize = 10;
  int totalRecordCount = 0;
  int? _currentBudget;
  int? _currentRating;
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
    _pagingController.addPageRequestListener((pageKey) {
      log(_sortType);
      context.read<AttractionBloc>().add(
            GetAttractionsWithFilter(
                locationId: widget.locationId,
                limit: pageSize,
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
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log(_sortType);
    // log(_parentTravelType == null ? "null" : _parentTravelType!.name);
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
                                  if (index == 1) {
                                    displayModal(
                                        context,
                                        ParentTravelTypeModal(
                                          currentTravelType: _parentTravelType,
                                          onTravelTypeChanged: (newTravelType) {
                                            setState(() {
                                              _parentTravelType = newTravelType;
                                              _pagingController.refresh();
                                            });
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
                                              _pagingController.refresh();
                                            });
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
                                              _pagingController.refresh();
                                            });
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
                                      options[index],
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
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextButton(
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
                          style: TextButton.styleFrom(
                            maximumSize: const Size(150, 100),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Phổ biến nhất",
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 70),
                    sliver: PagedSliverList<int, Attraction>(
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
                        noItemsFoundIndicatorBuilder: (_) =>
                            const Center(child: Text('Không có đánh giá nào.')),
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
    expand: expand ?? false,
    builder: (context) =>
        height != null ? SizedBox(height: height, child: child) : child,
  );
}
