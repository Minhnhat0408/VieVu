import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vievu/authenticated_view.dart';
import 'package:vievu/background_services.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/common/pages/introduction.dart';
import 'package:vievu/core/common/pages/splash_screen.dart';
import 'package:vievu/core/common/routes.dart';
import 'package:vievu/core/theme/theme.dart';
import 'package:vievu/core/theme/theme_provider.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/core/utils/text_theme.dart';
import 'package:provider/provider.dart';
import 'package:vievu/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vievu/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:vievu/features/auth/presentation/pages/profile_page.dart';
import 'package:vievu/features/auth/presentation/pages/reset_password.dart';
import 'package:vievu/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vievu/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vievu/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/nearby_attractions/nearby_attractions_cubit.dart';
import 'package:vievu/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vievu/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:vievu/features/notifications/presentation/pages/notification_page.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';
import 'package:vievu/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_review_bloc.dart';
import 'package:vievu/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vievu/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vievu/features/trips/presentation/pages/trip_detail_page.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vievu/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
import 'package:vievu/features/user_preference/presentation/pages/initial_preferences.dart';
import 'package:vievu/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await initDependencies();

  await Permission.notification.isDenied.then(
    (value) async {
      if (value) {
        await Permission.notification.request();
      }
    },
  );
  await initializeBackgroundService();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
      BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      BlocProvider(create: (_) => serviceLocator<PreferencesBloc>()),
      BlocProvider(create: (_) => serviceLocator<TravelTypesBloc>()),
      BlocProvider(create: (_) => serviceLocator<EventBloc>()),
      BlocProvider(create: (_) => serviceLocator<NearbyAttractionsCubit>()),
      BlocProvider(create: (_) => serviceLocator<SearchBloc>()),
      BlocProvider(create: (_) => serviceLocator<SearchHistoryCubit>()),
      BlocProvider(create: (_) => serviceLocator<TripBloc>()),
      BlocProvider(create: (_) => serviceLocator<SavedServiceBloc>()),
      BlocProvider(create: (_) => serviceLocator<TripDetailsCubit>()),
      BlocProvider(create: (_) => serviceLocator<TripItineraryBloc>()),
      BlocProvider(create: (_) => serviceLocator<ChatBloc>()),
      BlocProvider(create: (_) => serviceLocator<MessageBloc>()),
      BlocProvider(create: (_) => serviceLocator<ProfileBloc>()),
      BlocProvider(create: (_) => serviceLocator<TripMemberBloc>()),
      BlocProvider(create: (_) => serviceLocator<CurrentTripMemberInfoCubit>()),
      BlocProvider(create: (_) => serviceLocator<TripReviewBloc>()),
      BlocProvider(create: (_) => serviceLocator<NotificationBloc>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final service = FlutterBackgroundService();
  bool _isLoggedIn = false;
  Uri? _pendingUri;
  late final StreamSubscription<Uri?> _linkSub;
  @override
  void initState() {
    context.read<AuthBloc>().add(AuthUserLoggedIn());
    super.initState();
    AppLinks().getInitialLink().then((uri) {
      if (uri != null) {
        setState(() {
          _pendingUri = uri;
        });
      }
    });
    // wrap with mounted to avoid calling setState after dispose

    _linkSub = AppLinks().uriLinkStream.listen((uri) {
      log(uri.toString());
      if (_isLoggedIn) {
        setState(() {
          _pendingUri = uri;
          // log(_pendingUri.toString());
        });
      }
    });

    _checkDynamicLinks();
  }

  @override
  void dispose() {
    _linkSub.cancel();
    super.dispose();
  }

  Future<void> _checkDynamicLinks() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final res = await plugin.getNotificationAppLaunchDetails();
    if (res?.notificationResponse?.payload != null) {
      setState(() {
        _pendingUri = Uri.tryParse(res?.notificationResponse?.payload ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme =
        createTextTheme(context, "Merriweather", "Merriweather");

    MaterialTheme theme = MaterialTheme(textTheme);
    final brightness = MediaQuery.of(context).platformBrightness;

    return ChangeNotifierProvider(
      create: (BuildContext context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VieVu',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'), // Tiếng Việt
              // Thêm các ngôn ngữ khác nếu cần
            ],
            locale:
                const Locale('vi', 'VN'), // Đặt ngôn ngữ mặc định là tiếng Việt
            themeMode: notifier.isSystemOn
                ? brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light
                : notifier.isDarkMode
                    ? ThemeMode.light
                    : ThemeMode.dark,
            theme: theme.light(),
            darkTheme: theme.dark(),
            routes: routes,
            home: BlocConsumer<AppUserCubit, AppUserState>(
              listener: (context, state) {
                if (state is AppUserPasswordRecovery) {
                  showSnackbar(context, 'Tài khoản của bạn đã được khôi phục');
                }

                if (state is AppUserLoggedIn) {
                  setState(() {
                    _isLoggedIn = true;
                  });
                  context
                      .read<PreferencesBloc>()
                      .add(GetUserPreference(state.user.id));
                  Navigator.popUntil(context, (route) => route.isFirst);
                }

                if (state is AppUserInitial) {
                  context.read<PreferencesBloc>().add(UserPreferenceSignOut());
                  showSnackbar(context, 'Tài khoản của bạn đã đăng xuất');
                }
              },
              builder: (context, state) {
                if (state is AppUserInitial) {
                  return const SplashScreenPage();
                }
                if (state is AppUserLoggedIn) {
                  return BlocConsumer<PreferencesBloc, PreferencesState>(
                    listener: (context, state) {
                      if (state is PreferencesFailure) {
                        showSnackbar(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is PreferencesInitial) {
                        return const SplashScreenPage();
                      }
                      if (state is NoPreferencesExits) {
                        return const InitialPreferences();
                      }
                      if (state is PreferencesLoadedSuccess) {
                        if (_pendingUri != null &&
                            _pendingUri!.pathSegments.isNotEmpty) {
                          log(_pendingUri.toString());
                          if (_pendingUri!.pathSegments[0] == 'trip') {
                            final tripId = _pendingUri!.pathSegments.length > 1
                                ? _pendingUri!.pathSegments[1]
                                : null;
                            if (tripId != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TripDetailPage(
                                        tripId: tripId,
                                      ),
                                    ),
                                  );
                                  _pendingUri = null;
                                }
                              });
                            }
                          } else if (_pendingUri!.pathSegments[0] ==
                              'notifications') {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationPage(),
                                  ),
                                );
                              }
                            });
                          } else if (_pendingUri!.pathSegments[0] ==
                              'attraction') {
                            final attractionId =
                                _pendingUri!.pathSegments.length > 1
                                    ? _pendingUri!.pathSegments[1]
                                    : null;
                            if (attractionId != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttractionDetailPage(
                                        attractionId: int.tryParse(
                                              attractionId ?? '0',
                                            ) ??
                                            0,
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                          } else if (_pendingUri!.pathSegments[0] ==
                              'profile') {
                            final profileId =
                                _pendingUri!.pathSegments.length > 1
                                    ? _pendingUri!.pathSegments[1]
                                    : null;
                            log("profileId: $profileId");
                            if (profileId != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        id: profileId,
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                          } else if (_pendingUri!.pathSegments[0] ==
                              'location') {
                            // final locationId =
                            //     _pendingUri!.pathSegments.length > 1
                            //         ? _pendingUri!.pathSegments[1]
                            //         : null;
                            // if (locationId != null) {
                            //   WidgetsBinding.instance.addPostFrameCallback((_) {
                            //     if (mounted) {
                            //       Navigator.of(context).push(
                            //         MaterialPageRoute(
                            //           builder: (context) => LocationDetailPage(
                            //             locationId: int.tryParse(
                            //                   locationId,
                            //                 ) ??
                            //                 0,
                            //             // locationName: ,
                            //           ),
                            //         ),
                            //       );
                            //     }
                            //   });
                            // }
                          }

                          _pendingUri = null;
                        }
                        return const AuthenticatedView();
                      }
                      return const SplashScreenPage();
                    },
                  );
                }

                if (state is AppUserPasswordRecovery) {
                  return const ResetPasswordPage();
                }

                return const IntroductionPage();
              },
            ),
          );
        },
      ),
    );
  }
}
