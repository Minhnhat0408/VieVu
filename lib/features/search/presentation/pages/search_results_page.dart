import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/widgets/explore_search_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchResultsPage extends StatefulWidget {
  final String keyword;
  final bool ticketBox;
  const SearchResultsPage({
    super.key,
    required this.keyword,
    this.ticketBox = false,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final PagingController<int, ExploreSearchResult> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _filterOptions = [
    'Sự kiện',
    'Địa điểm du lịch', // Attractions
    'Điểm đến', // Locations
    'Loại hình du lịch', // Travel Types
  ];

  int totalRecordCount = 0;
  final int pageSize = 10;
  String _selectedFilter = ''; // Default filter is 'All'

  @override
  void initState() {
    super.initState();
    _selectedFilter =
        widget.ticketBox ? 'Sự kiện' : ''; // Use 'Sự kiện' if ticketBox is true

    // Listen for pagination events
    _pagingController.addPageRequestListener((pageKey) {
      if (_selectedFilter == 'Sự kiện') {
        context.read<SearchBloc>().add(EventsSearch(
              searchText: widget.keyword,
              limit: pageSize,
              page: (pageKey ~/ pageSize) + 1,
            ));
      } else {
        context.read<SearchBloc>().add(ExploreSearch(
              searchText: widget.keyword,
              limit: pageSize,
              offset: pageKey,
              searchType: _mapFilterToSearchType(_selectedFilter),
            ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: '"${widget.keyword}"',
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search-page',
                arguments: widget.keyword);
          },
          icon: const Icon(Icons.search),
        ),
      ],
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchSuccess) {
            totalRecordCount += state.results.length;
            final next = totalRecordCount;

            final isLastPage = state.results.length < pageSize;
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
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Kết quả tìm kiếm',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: FilterOptionsBig(
                        options: _filterOptions,
                        selectedOption: _selectedFilter,
                        onOptionSelected: _onFilterChanged,
                        isFiltering: state is SearchLoading)),
              ),
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
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    noItemsFoundIndicatorBuilder: (_) =>
                        const Center(child: Text('No results found')),
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
