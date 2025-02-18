import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/saved_service/saved_service_small_card.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class AddSavedServicesPage extends StatelessWidget {
  final Trip trip;
  final int? searchType;
  const AddSavedServicesPage({super.key, required this.trip, this.searchType});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AttractionDetailsCubit>()),
        BlocProvider(create: (_) => serviceLocator<LocationBloc>()),
        BlocProvider(create: (_) => serviceLocator<LocationInfoCubit>()),
      ],
      child: AddSavedServicesPageView(trip: trip, searchType: searchType),
    );
  }
}

class AddSavedServicesPageView extends StatefulWidget {
  final Trip trip;
  final int? searchType;

  const AddSavedServicesPageView(
      {super.key, required this.trip, this.searchType});

  @override
  State<AddSavedServicesPageView> createState() =>
      _AddSavedServicesPageViewState();
}

class _AddSavedServicesPageViewState extends State<AddSavedServicesPageView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  final PagingController<int, ExploreSearchResult> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _filterOptions = [
    'Địa điểm du lịch', // Attractions
    'Nhà hàng', // Restaurants
    'Khách sạn', // Hotels
    'Sự kiện',
    'Điểm đến', // Locations
  ];
  int totalRecordCount = 0;
  final int pageSize = 10;
  String _selectedFilter = ''; // Default filter is 'All'

  // Handle text changes with debounce
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      log('searching for $keyword');
      setState(() {
        _keyword = keyword;
      });
      _keyword = keyword;

      _pagingController.refresh();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedFilter = _mapTypeIndexToFilter(widget.searchType ?? -1);
    context.read<SearchHistoryCubit>().getSearchHistory(
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id);

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _pagingController.addPageRequestListener((pageKey) {
      if (_selectedFilter == 'Sự kiện') {
        context.read<SearchBloc>().add(EventsSearch(
              searchText: _keyword,
              limit: pageSize,
              tripId: widget.trip.id,
              page: (pageKey ~/ pageSize) + 1,
            ));
      } else if (_selectedFilter == 'Khách sạn' ||
          _selectedFilter == 'Nhà hàng' ||
          _selectedFilter == 'Cửa hàng') {
        log('calling external api');
        context.read<SearchBloc>().add(SearchExternalApi(
              searchText: _keyword,
              limit: pageSize,
              tripId: widget.trip.id,
              page: (pageKey ~/ pageSize) + 1,
              searchType: _mapFilterToSearchType(_selectedFilter),
            ));
      } else {
        context.read<SearchBloc>().add(ExploreSearch(
              searchText: _keyword,
              limit: pageSize - 1,
              offset: pageKey,
              searchType: _mapFilterToSearchType(_selectedFilter),
              tripId: widget.trip.id,
            ));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _pagingController.dispose();
    super.dispose();
  }

  String _mapFilterToSearchType(String filter) {
    switch (filter) {
      case 'Địa điểm du lịch':
        return 'attractions';
      case 'Điểm đến':
        return 'locations';
      case 'Sự kiện':
        return 'events';
      case 'Loại hình du lịch':
        return 'travel_types';
      case 'Khách sạn':
        return 'hotel';
      case 'Nhà hàng':
        return 'restaurant';

      default:
        return 'all';
    }
  }

  String _mapTypeIndexToFilter(int index) {
    switch (index) {
      case 2:
        return 'Địa điểm du lịch';
      case 1:
        return 'Nhà hàng';
      case 4:
        return 'Khách sạn';
      case 5:
        return 'Sự kiện';
      case 0:
        return 'Điểm đến';
      default:
        return '';
    }
  }

  void _onFilterChanged(String selectedFilter) {
    setState(() {
      if (_selectedFilter == selectedFilter) {
        _selectedFilter =
            ''; // Reset to '' if the same filter is selected again
      } else {
        _selectedFilter = selectedFilter;
      }

      totalRecordCount = 0; // Reset total record count for new search
    });

    // Reset paging controller to fetch new data based on selected filter
    _pagingController.refresh();
  }

  void changeSearchText(String text) {
    _searchController.text = text;
    _onSearchChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 40,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.close),
                iconSize: 28,
                padding: const EdgeInsets.all(0),
                highlightColor: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        centerTitle: true,
        toolbarHeight: 90,
        title: Hero(
          tag: 'exploreSearch',
          child: SearchBar(
            controller: _searchController,
            autoFocus: true,
            elevation: const WidgetStatePropertyAll(0),
            leading: const Icon(Icons.search),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<SearchBloc>().add(SearchHistory(
                      searchText: value,
                      userId: (context.read<AppUserCubit>().state
                              as AppUserLoggedIn)
                          .user
                          .id,
                    ));
              }
            },
            onChanged: (value) {
              setState(() {});
            },
            trailing: _searchController.text.isEmpty
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  ],
            hintText: 'Tìm kiếm địa điểm du lịch...',
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchSuccess) {
            totalRecordCount += state.results.length;
            final next = totalRecordCount;

            final isLastPage = state.results.isEmpty;
            if (isLastPage) {
              _pagingController.appendLastPage(state.results);
            } else {
              _pagingController.appendPage(state.results, next);
            }
          }
          if (state is SearchError) {
            _pagingController.error = state.message;
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              if (_keyword.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: FilterOptionsBig(
                          options: _filterOptions,

                          selectedOption: _selectedFilter,
                          onOptionSelected: _onFilterChanged,
                          isFiltering: state is SearchLoading)),
                ),
              SliverToBoxAdapter(
                child: Divider(
                  height: 20,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              if (_keyword.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 70.0),
                  sliver: PagedSliverList<int, ExploreSearchResult>(
                    pagingController: _pagingController,
                    builderDelegate:
                        PagedChildBuilderDelegate<ExploreSearchResult>(
                      itemBuilder: (context, item, index) {
                        return SavedServiceSmallCard(
                            result: item,
                            isDetailed: true,
                            onSavedChange: (bool isSaved) {
                              setState(() {
                                _pagingController.itemList![index].isSaved =
                                    isSaved;
                              });
                            });
                      },
                      firstPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      newPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      noItemsFoundIndicatorBuilder: (_) =>
                          const Center(child: Text('Không có kết quả nào.')),
                      newPageErrorIndicatorBuilder: (context) => Center(
                        child: TextButton(
                          onPressed: () =>
                              _pagingController.retryLastFailedRequest(),
                          child: const Text('Retry'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
