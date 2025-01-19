import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore_main_page.dart';

class ExploreNestedRoutes extends StatelessWidget {
  const ExploreNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/attraction':
              final attractionId = settings.arguments as int;
              page = AttractionDetailPage(attractionId: attractionId);
            default:
              page = const ExploreMainPage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
