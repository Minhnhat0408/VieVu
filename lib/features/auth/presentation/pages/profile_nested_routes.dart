import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/pages/settings.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';

class ProfileNestedRoutes extends StatelessWidget {
  const ProfileNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/profile':
              final id = settings.arguments;
              page = ProfilePage(
                id: id as String,
              );
              break;
            default:
              page = const SettingsPage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
