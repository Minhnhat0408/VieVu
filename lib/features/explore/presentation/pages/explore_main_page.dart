import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/recommended_attractions_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/explore_appbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/hot_attractions_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/events/hot_events.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/hot_locations.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/nearby_attraction.dart';
import 'package:vn_travel_companion/features/search/presentation/pages/search_results_page.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class ExploreMainPage extends StatefulWidget {
  const ExploreMainPage({super.key});

  @override
  State<ExploreMainPage> createState() => _ExploreMainPageState();
}

class _ExploreMainPageState extends State<ExploreMainPage> {
  bool refresh = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Handle refresh
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            // Refresh logic, e.g., reload data from API
            refresh = !refresh;
          });
        },
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              leading: null,
              scrolledUnderElevation: 0,
              collapsedHeight: 70,
              foregroundColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.surface,
              flexibleSpace: const ExploreAppbar(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 40, // Set the height for your horizontal scroll view
                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal, // This makes it horizontal
                    itemCount: 1, // Number of buttons
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 20 : 4.0, // Padding for first item
                          right: index == 9 ? 20 : 4.0, // Padding for last item
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchResultsPage(
                                  keyword: 'faefse',
                                  ticketBox: false,
                                ),
                              ),
                            );
                          },
                          child: const Hero(
                              tag: 'nope', child: Text('Xem gần đây')),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
                padding: const EdgeInsets.only(bottom: 40.0),
                sliver: SliverToBoxAdapter(
                    child: BlocProvider(
                  create: (context) => serviceLocator<AttractionBloc>(),
                  child: const HotAttractionsSection(),
                ))),
            SliverPadding(
                padding: const EdgeInsets.only(bottom: 40.0),
                sliver: SliverToBoxAdapter(
                    child: BlocProvider(
                  create: (context) => serviceLocator<AttractionBloc>(),
                  child: const RecommendedAttractionSection(),
                ))),
            const SliverPadding(
                padding: EdgeInsets.only(bottom: 40.0),
                sliver: SliverToBoxAdapter(child: NearbyAttractionSection())),
            const SliverPadding(
                padding: EdgeInsets.only(bottom: 40.0),
                sliver: SliverToBoxAdapter(child: HotEventsSection())),
            SliverPadding(
                padding: const EdgeInsets.only(bottom: 40.0),
                sliver: SliverToBoxAdapter(
                    child: BlocProvider(
                  create: (context) => serviceLocator<LocationBloc>(),
                  child: const HotLocationsSection(),
                ))),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80))
          ],
        ),
      ),
    );
  }
}
