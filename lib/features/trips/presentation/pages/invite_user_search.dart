import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vievu/features/search/domain/entities/home_search_result.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';

class InviteUserSearch extends StatefulWidget {
  final Trip trip;
  const InviteUserSearch({super.key, required this.trip});

  @override
  State<InviteUserSearch> createState() => _InviteUserSearchState();
}

class _InviteUserSearchState extends State<InviteUserSearch> {
  final PagingController<int, HomeSearchResult> _pagingController =
      PagingController(firstPageKey: 0);

  int totalRecordCount = 0;
  final int pageSize = 10;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  void changeSearchText(String text) {
    _searchController.text = text;
    _onSearchChanged(text);
  }

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

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _pagingController.addPageRequestListener((pageKey) {
      context.read<SearchBloc>().add(SearchHome(
            searchText: _keyword,
            searchType: 'profile',
            offset: pageKey,
            limit: pageSize,
          ));
    });
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
            onSubmitted: (value) {},
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
                            imageUrl: item.cover ?? "",
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(child: Icon(Icons.person)),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
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
                          trailing: const Icon(Icons.person),
                          onTap: () {
                            context.read<TripMemberBloc>().add(
                                  InviteTripMember(
                                    tripId: widget.trip.id,
                                    userId: item.id,
                                  ),
                                );
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
