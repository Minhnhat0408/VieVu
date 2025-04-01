import 'package:flutter/material.dart';
import 'package:vievu/core/common/pages/settings.dart';
import 'package:vievu/features/auth/presentation/pages/profile_page.dart';

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
              page = const SettingsPage(
                unreadCount: 0,
              );
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
