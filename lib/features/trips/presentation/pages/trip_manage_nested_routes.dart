import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';

import 'package:vn_travel_companion/features/trips/presentation/pages/trip_manage_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';

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
            case '/trip-detail':
              final trip = settings.arguments;
              page = TripDetailPage(trip: trip as Trip);
              break;

            case '/trip-settings':
              final trip = settings.arguments;

              page = TripSettingsPage(trip: trip as Trip);
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
