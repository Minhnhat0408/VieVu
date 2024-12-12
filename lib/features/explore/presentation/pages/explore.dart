import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/explore_appbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hot_attractions_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hot_locations.dart';

class ExplorePage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const ExplorePage());
  }

  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  scrollDirection: Axis.horizontal, // This makes it horizontal
                  itemCount: 10, // Number of buttons
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 20 : 4.0, // Padding for first item
                        right: index == 9 ? 20 : 4.0, // Padding for last item
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        child: const Text('Xem gần đây'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SliverPadding(
              padding: EdgeInsets.only(bottom: 40.0),
              sliver: SliverToBoxAdapter(child: HotAttractionsSection())),
          const SliverPadding(
              padding: EdgeInsets.only(bottom: 40.0),
              sliver: SliverToBoxAdapter(child: HotLocationsSection())),
          // const SliverPadding(
          //     padding: EdgeInsets.only(bottom: 40.0),
          //     sliver: SliverToBoxAdapter(child: HotAttractionsSection())),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80))
        ],
      ),
    );
  }
}
