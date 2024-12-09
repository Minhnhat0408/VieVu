import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/pages/splash_screen.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/log_in.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore.dart';
import 'package:vn_travel_companion/features/settings/presentation/pages/settings.dart';

class AuthenticatedView extends StatefulWidget {
  const AuthenticatedView({super.key});

  @override
  State<AuthenticatedView> createState() => _AuthenticatedViewState();
}

class _AuthenticatedViewState extends State<AuthenticatedView> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    const SettingsPage(),
    const SplashScreenPage(),
    const ExplorePage(),
    const SplashScreenPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      Icon(
        Icons.home_outlined,
        size: _selectedIndex == 0 ? 36 : 30,
      ),
      Icon(
        Icons.tour_outlined,
        size: _selectedIndex == 1 ? 36 : 30,
      ),
      Icon(
        Icons.search,
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
      body: screens[_selectedIndex],
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
