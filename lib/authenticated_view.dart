import 'dart:developer';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/common/pages/settings.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/pages/all_chats_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore_nested_routes.dart';
import 'package:vn_travel_companion/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:vn_travel_companion/features/notifications/presentation/pages/notification_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_manage_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_posts_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class AuthenticatedView extends StatefulWidget {
  const AuthenticatedView({super.key});

  @override
  State<AuthenticatedView> createState() => _AuthenticatedViewState();
}

class _AuthenticatedViewState extends State<AuthenticatedView> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _selectedIndex = 0;
  SupabaseClient client = serviceLocator<SupabaseClient>();
  int _unreadNotificationsCount = 0;
  int _unreadMessagesCount = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<NotificationBloc>().add(GetUnreadNotificationsCount());

    service.on('newNotification').listen((payload) {
      log('New notification: $payload');

      final event = payload!['eventType'];
      if (event == 'update') {
        final data = payload['newRecord'];
        if (data['is_read'] == false) {
          setState(() {
            _unreadNotificationsCount++;
          });
        } else {
          setState(() {
            _unreadNotificationsCount--;
          });
        }
      } else if (event == 'insert') {
        setState(() {
          _unreadNotificationsCount++;
        });
      }
    });

    service.on('redirecting').listen((data) {
      log('Redirect: $data');
      // setState(() {
      //   _selectedIndex = 4;
      // });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const NotificationPage();
      }));
    });

    client
        .channel("chat_realtime:$userId")
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            // log('Payload: $payload');
            context.read<ChatBloc>().add(GetChatHeads());
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    client.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TripPostsPage(),
      const TripManagePage(),
      const ExploreNestedRoutes(),
      const AllMessagesPage(),
      SettingsPage(
        unreadCount: _unreadNotificationsCount,
      ),
    ];
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
      body: LazyLoadIndexedStack(
        index: _selectedIndex,
        preloadIndexes: const [1, 2],
        autoDisposeIndexes: const [4],
        children: screens,
      ),
      // ),
      bottomNavigationBar: MultiBlocListener(
        listeners: [
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is UnreadNotificationsCount) {
                setState(() {
                  log('Unread notifications count: ${state.count}');
                  _unreadNotificationsCount = state.count;
                });
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              // TODO: implement listener
              if (state is ChatsLoadedSuccess) {
                setState(() {
                  _unreadMessagesCount = state.chatHeads
                      .where((element) => element.isSeen == false)
                      .toList()
                      .length;
                });
              }
            },
          ),
        ],
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _selectedIndex,
          backgroundColor: Colors.transparent,
          color: Theme.of(context).colorScheme.primaryContainer,
          items: items
              .asMap()
              .entries
              .map(
                (item) => item.key == 3 || item.key == 4
                    ? Stack(
                        children: [
                          item.value,
                          if (item.key == 3 && _unreadMessagesCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 10,
                                child: Text(
                                  '$_unreadMessagesCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          if (item.key == 4 && _unreadNotificationsCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 10,
                                child: Text(
                                  '$_unreadNotificationsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      )
                    : item.value,
              )
              .toList(),
          buttonBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          height: 54,
          onTap: (index) {
            //Handle button tap

            _onItemTapped(index);
          },
        ),
      ),
    );
  }
}
