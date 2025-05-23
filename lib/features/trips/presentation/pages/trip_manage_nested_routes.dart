import 'package:flutter/material.dart';
import 'package:vievu/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/pages/trip_manage_page.dart';
import 'package:vievu/features/trips/presentation/pages/trip_settings_page.dart';

class TripManageNestedRoutes extends StatelessWidget {
  const TripManageNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/trip-settings':
              final trip = settings.arguments;

              page = TripSettingsPage(trip: trip as Trip);
              break;
            case '/attraction':
              final attractionId = settings.arguments as int;
              page = AttractionDetailPage(attractionId: attractionId);
              break;

            case '/location':
              final location = settings.arguments as Map<String, dynamic>;
              page = LocationDetailPage(
                locationId: location['locationId'],
                locationName: location['locationName'],
              );
              break;
            default:
              page = const TripManagePage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
