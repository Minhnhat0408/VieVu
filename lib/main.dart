import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vn_travel_companion/authenticated_view.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/common/pages/introduction.dart';
import 'package:vn_travel_companion/core/common/pages/splash_screen.dart';
import 'package:vn_travel_companion/core/common/routes.dart';
import 'package:vn_travel_companion/core/theme/theme.dart';
import 'package:vn_travel_companion/core/theme/theme_provider.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/text_theme.dart';
import 'package:provider/provider.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/reset_password.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_attractions/nearby_attractions_cubit.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/pages/initial_preferences.dart';
import 'package:vn_travel_companion/init_dependencies.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initDependencies();

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
  @override
  void initState() {
    context.read<AuthBloc>().add(AuthUserLoggedIn());
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    super.initState();
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
            title: 'VietNam Travel Companion App',
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
                    ? ThemeMode.dark
                    : ThemeMode.light,
            theme: theme.light(),
            darkTheme: theme.dark(),
            routes: routes,
            home: BlocConsumer<AppUserCubit, AppUserState>(
              listener: (context, state) {
                if (state is AppUserPasswordRecovery) {
                  showSnackbar(context, 'Tài khoản của bạn đã được khôi phục');
                }

                if (state is AppUserLoggedIn) {
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
