import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavScaffold extends StatefulWidget {
  final Widget body; // Accepts a widget for the body
  final String? appBarTitle; // Optional title for the app bar
  final List<Widget>? actions; // Optional actions for the app bar

  const BottomNavScaffold({
    super.key,
    required this.body, // The body is required
    this.appBarTitle, // AppBar title is optional
    this.actions, // AppBar actions are optional
  });

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to home
      // Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      // Navigate to tours
      // Navigator.pushNamed(context, '/trip');
    } else if (index == 2) {
      // Navigate to search
      // Navigator.pushNamed(context, '/explore');
    } else if (index == 3) {
      // Navigate to messages
      // Navigator.pushNamed(context, '/message');
    } else if (index == 4) {
      // Navigate to account
      // Navigator.pushNamed(context, '/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 36,
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back
                },
              )
            : null,
        title: widget.appBarTitle != null ? Text(widget.appBarTitle!) : null,
        actions: widget.actions,
      ),
      body: widget.body,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(context).colorScheme.primaryContainer,
        items: <Widget>[
          Icon(
            Icons.home_outlined,
            size: _selectedIndex == 0 ? 36 : 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.tour_outlined,
            size: _selectedIndex == 1 ? 36 : 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.search,
            size: _selectedIndex == 2 ? 36 : 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.message_outlined,
            size: _selectedIndex == 3 ? 36 : 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.account_circle_outlined,
            size: _selectedIndex == 4 ? 36 : 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
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
