import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_posts_page.dart';

class HomeNestedRoutes extends StatelessWidget {
  const HomeNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            default:
              page = const TripPostsPage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
