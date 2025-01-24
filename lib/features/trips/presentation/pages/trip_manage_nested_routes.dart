import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_manage_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_manage_page.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

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
            default:
              page =  const TripManagePage();

          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
