import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/common/pages/introduction.dart';
import 'package:vn_travel_companion/core/common/routes.dart';
import 'package:vn_travel_companion/core/theme/theme.dart';
import 'package:vn_travel_companion/core/theme/theme_provider.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/text_theme.dart';
import 'package:provider/provider.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/reset_password.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/pages/initial_preferences.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initDependencies();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme =
        createTextTheme(context, "Be Vietnam Pro", "Be Vietnam Pro");

    MaterialTheme theme = MaterialTheme(textTheme);

    return ChangeNotifierProvider(
      create: (BuildContext context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VietNam Travel Companion App',
            themeMode: notifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: theme.light(),
            darkTheme: theme.dark(),
            routes: routes,
            home: BlocConsumer<AppUserCubit, AppUserState>(
              listener: (context, state) {
                if (state is AppUserPasswordRecovery) {
                  showSnackbar(context, 'Tài khoản của bạn đã được khôi phục');
                }

                if (state is AppUserLoggedIn) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              builder: (context, state) {
                if (state is AppUserLoggedIn) {
                  return const InitialPreferences();
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
