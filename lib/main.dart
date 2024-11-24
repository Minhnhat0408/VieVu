import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/pages/introduction.dart';
import 'package:vn_travel_companion/core/theme/theme.dart';
import 'package:vn_travel_companion/core/theme/theme_provider.dart';
import 'package:vn_travel_companion/core/utils/text_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            home: const IntroductionPage(),
          );
        },
      ),
    );
  }
}
