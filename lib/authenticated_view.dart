import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_nested_routes.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore_nested_routes.dart';
import 'package:vn_travel_companion/features/chat/presentation/pages/chats_nested_routes.dart';
import 'package:vn_travel_companion/core/common/pages/settings.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/home_nested_routes.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_manage_nested_routes.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_posts_page.dart';

class AuthenticatedView extends StatefulWidget {
  const AuthenticatedView({super.key});

  @override
  State<AuthenticatedView> createState() => _AuthenticatedViewState();
}

class _AuthenticatedViewState extends State<AuthenticatedView> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;
  bool reversedTrans = false;
  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex > index) {
        reversedTrans = true;
      } else {
        reversedTrans = false;
      }
      _selectedIndex = index;
    });
  }

  final screens = [
    const HomeNestedRoutes(),
    const TripManageNestedRoutes(),
    const ExploreNestedRoutes(),
    const ChatsNestedRoutes(),
    const ProfileNestedRoutes(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      Icon(
        Icons.home_outlined,
        size: _selectedIndex == 0 ? 36 : 30,
      ),
      Icon(
        Icons.card_travel,
        size: _selectedIndex == 1 ? 36 : 30,
      ),
      Icon(
        Icons.travel_explore,
        size: _selectedIndex == 2 ? 36 : 30,
      ),
      Icon(
        Icons.message_outlined,
        size: _selectedIndex == 3 ? 36 : 30,
      ),
      Icon(
        Icons.account_circle_outlined,
        size: _selectedIndex == 4 ? 36 : 30,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      // ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primaryContainer,
        items: items,
        buttonBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        height: 54,
        onTap: (index) {
          //Handle button tap

          _onItemTapped(index);
        },
      ),
    );
  }
}
