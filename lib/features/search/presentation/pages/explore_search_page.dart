import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/widgets/explore_search_item.dart';
import 'package:vn_travel_companion/features/search/presentation/widgets/search_keyword.dart';

class ExploreSearchPage extends StatefulWidget {
  static route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ExploreSearchPage(),
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
  List<ExploreSearchResult> _results = [];
  String _keyword = '';

  // Handle text changes with debounce
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (keyword.isNotEmpty) {
        _keyword = keyword;
        context.read<SearchBloc>().add(SearchAll(
              searchText: keyword,
              limit: 5,
              offset: 0,
            ));
      } else {
        setState(() => _results = []);
      }
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
                highlightColor: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        centerTitle: true,
        toolbarHeight: 90,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Thickness of the line
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer, // Line color
            height: 1.0, // Line thickness
          ),
        ),
        title: Hero(
          tag: 'exploreSearch',
          child: SearchBar(
            controller: _searchController,
            autoFocus: true,
            elevation: const WidgetStatePropertyAll(0),
            leading: const Icon(Icons.search),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.pushNamed(context, '/search-results',
                    arguments: {'keyword': value, 'ticketBox': false});
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
                        setState(() {
                          _results = [];
                        });
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
          if (state is SearchOverAllSuccess) {
            setState(() {
              _results = state.results;
            });
          }
          if (state is SearchError) {
            showSnackbar(
              context,
              state.message,
              'error',
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state is SearchLoading)
                const LinearProgressIndicator(), // Show loading indicator
              const SizedBox(height: 10),
              Expanded(
                child: _results.isEmpty
                    ? const Column(children: [
                        ExploreSearchItem(),
                        SizedBox(height: 20),
                      ])
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          // Check if this is the first 'event' type item
                          if (result.type == 'event') {
                            // Add a header above the first event type item
                            if (index == 0 ||
                                _results[index - 1].type != 'event') {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SearchKeyword(keyword: _keyword),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        top: 20.0,
                                        bottom: 10,
                                        left: 20,
                                        right: 20),
                                    child: Text(
                                      'Kết quả tìm kiếm trên TicketBox',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ExploreSearchItem(
                                    result: result,
                                  ),
                                  if (index == _results.length - 1)
                                    SearchKeyword(
                                        keyword: _keyword, ticketBox: true)
                                ],
                              );
                            }
                          }

                          if (index == _results.length - 1) {
                            return SearchKeyword(
                                keyword: _keyword, ticketBox: true);
                          }
                          // Render other items normally
                          return ExploreSearchItem(
                            result: result,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
