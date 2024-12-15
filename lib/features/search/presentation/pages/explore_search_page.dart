import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/widgets/explore_search_item.dart';

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

  const ExploreSearchPage({super.key});

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; 
  List<ExploreSearchResult> _results = []; 

  // Handle text changes with debounce
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (keyword.isNotEmpty) {
        context.read<SearchBloc>().add(ExploreSearch(
              searchText: keyword,
              limit: 10,
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
            elevation: const WidgetStatePropertyAll(0),
            leading: const Icon(Icons.search),
            hintText: 'Tìm kiếm địa điểm du lịch...',
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16)),
          ),
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchSuccess) {
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
              Expanded(
                child: _results.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(children: [
                          ExploreSearchItem(),
                          SizedBox(height: 20),
                        ]),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return ExploreSearchItem(
                              result: result,
                            );
                          },
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
