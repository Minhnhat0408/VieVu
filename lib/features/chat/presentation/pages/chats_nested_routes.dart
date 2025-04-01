import 'package:flutter/material.dart';
import 'package:vievu/features/chat/presentation/pages/all_chats_page.dart';

class ChatsNestedRoutes extends StatelessWidget {
  const ChatsNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            default:
              page = const AllMessagesPage();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
