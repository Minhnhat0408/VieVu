import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:vn_travel_companion/features/search/presentation/widgets/explore_search_item.dart';

class ExploreSearchPage extends StatefulWidget {
  static route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ExploreSearchPage(),
      fullscreenDialog: true,

      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Return a FadeTransition for the page content change
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      }, // Set duration
    );
  }

  final String? initialKeyword;
  const ExploreSearchPage({super.key, this.initialKeyword});

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  final PagingController<int, ExploreSearchResult> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _filterOptions = [
    'Sự kiện',
    'Địa điểm du lịch', // Attractions
    'Điểm đến', // Locations
    'Khách sạn', // Hotels
    'Nhà hàng', // Restaurants
    'Cửa hàng', // Shops
    'Loại hình du lịch', // Travel Types
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
    context.read<SearchHistoryCubit>().getSearchHistory(
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id);
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _pagingController.addPageRequestListener((pageKey) {
      if (_selectedFilter == 'Sự kiện') {
        context.read<SearchBloc>().add(EventsSearch(
              searchText: _keyword,
              limit: pageSize,
              page: (pageKey ~/ pageSize) + 1,
            ));
      } else if (_selectedFilter == 'Khách sạn' ||
          _selectedFilter == 'Nhà hàng' ||
          _selectedFilter == 'Cửa hàng') {
        log('calling external api');
        context.read<SearchBloc>().add(SearchExternalApi(
              searchText: _keyword,
              limit: pageSize,
              page: (pageKey ~/ pageSize) + 1,
              searchType: _mapFilterToSearchType(_selectedFilter),
            ));
      } else {
        context.read<SearchBloc>().add(ExploreSearch(
              searchText: _keyword,
              limit: pageSize,
              offset: pageKey,
              searchType: _mapFilterToSearchType(_selectedFilter),
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
      case 'Cửa hàng':
        return 'shop';
      default:
        return 'all';
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
                icon: const Icon(Icons.chevron_left),
                iconSize: 36,
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
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: FilterOptionsBig(
                        options: _keyword.isEmpty
                            ? ["Tìm kiếm gần đây"]
                            : _filterOptions,
                        selectedOption: _keyword.isEmpty
                            ? "Tìm kiếm gần đây"
                            : _selectedFilter,
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
              if (_keyword.isEmpty)
                SliverToBoxAdapter(
                  child: BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
                    builder: (context, state) {
                      if (state is SearchHistoryLoading) {
                        return const SizedBox(
                          height: 600,
                          child: Center(
                              child: CircularProgressIndicator.adaptive()),
                        );
                      }

                      if (state is SearchHistorySuccess) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExploreSearchItem(
                                changeSearchText: changeSearchText,
                              ),
                              ...state.searchHistory.map((e) =>
                                  ExploreSearchItem(
                                      result: e,
                                      changeSearchText: changeSearchText)),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
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
                        return ExploreSearchItem(
                            result: item,
                            isDetailed: true,
                            changeSearchText: changeSearchText);
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
