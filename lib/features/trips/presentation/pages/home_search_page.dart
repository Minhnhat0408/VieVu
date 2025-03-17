import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/features/search/domain/entities/home_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';

class HomeSearchPage extends StatefulWidget {
  final String? initialKeyword;
  const HomeSearchPage({super.key, this.initialKeyword});

  @override
  State<HomeSearchPage> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  final PagingController<int, HomeSearchResult> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _filterOptions = [
    'Tất cả',
    'Người dùng',
    'Chuyến đi',
  ];
  int totalRecordCount = 0;
  final int pageSize = 10;
  String _selectedFilter = 'Tất cả'; // Default filter is 'All'

  // Handle text changes with debounce
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
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

    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _pagingController.addPageRequestListener((pageKey) {
      context.read<SearchBloc>().add(SearchHome(
            searchText: _keyword,
            searchType: _mapFilterToSearchType(_selectedFilter),
            offset: pageKey,
            limit: pageSize,
          ));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _pagingController.dispose();
    super.dispose();
  }

  String? _mapFilterToSearchType(String filter) {
    switch (filter) {
      case 'Người dùng':
        return 'profile';
      case 'Chuyến đi':
        return 'trip';

      default:
        return null;
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
          tag: 'homeSearch',
          child: SearchBar(
            controller: _searchController,
            autoFocus: true,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            elevation: const WidgetStatePropertyAll(0),
            leading: const Icon(Icons.search),
            onSubmitted: (value) {

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
          if (state is SearchHomeSuccess) {
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
                        key: _keyword.isEmpty
                            ? const Key('searchHistory')
                            : const Key('searchResults'),
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
                  sliver: PagedSliverList<int, HomeSearchResult>(
                    pagingController: _pagingController,
                    builderDelegate:
                        PagedChildBuilderDelegate<HomeSearchResult>(
                      itemBuilder: (context, item, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CachedNetworkImage(
                            imageUrl: item.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: item.type == 'trip'
                                    ? BoxShape.rectangle
                                    : BoxShape.circle,
                                // borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          minLeadingWidth: 60,
                          title: Text(item.name),
                          subtitle: item.locations != null
                              ? Text(item.locations ?? "",
                                  maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: item.type == 'trip'
                              ? const Icon(Icons.card_travel)
                              : const Icon(Icons.person),
                          onTap: () {
                            // context.read<SearchBloc>().add(SearchHistory(
                            //       searchText: item.title,
                            //       userId: (context.read<AppUserCubit>().state
                            //               as AppUserLoggedIn)
                            //           .user
                            //           .id,
                            //     ));
                            if (item.type == 'trip') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TripDetailPage(
                                    tripId: item.id,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    id: item.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
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
