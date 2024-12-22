import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore_main_page.dart';
import 'package:vn_travel_companion/features/search/presentation/pages/explore_search_page.dart';
import 'package:vn_travel_companion/features/search/presentation/pages/search_results_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/search-results':
              final keyword = settings.arguments as Map<String, dynamic>;

              page = SearchResultsPage(
                keyword: keyword['keyword'],
                ticketBox: keyword['ticketBox'],
              );
              break;
            case '/search-page':
              final keyword = settings.arguments as String;

              page = ExploreSearchPage(
                initialKeyword: keyword,
              );
              break;
            case '/attraction':
              final attractionId = settings.arguments as int;
              page = AttractionDetailsPage(attractionId: attractionId);
            default:
              page = const ExploreMainPage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
