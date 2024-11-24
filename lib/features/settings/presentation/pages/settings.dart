import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vn_travel_companion/core/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const SettingsPage());
  }

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          Consumer<ThemeProvider>(builder: (context, notifier, child) {
            return IconButton(
                onPressed: () {
                  context.read<ThemeProvider>().themeOnChanged();
                },
                icon: Icon(
                    notifier.isDarkMode ? Icons.dark_mode : Icons.light_mode));
          })
        ],
      ),
      body: Consumer<ThemeProvider>(builder: (context, notifier, child) {
        return Column(
          children: [
            _box(
                title: "Application Theme",
                subtitle: notifier.isDarkMode ? "Dark Theme" : "Light Theme",
                leading: Icons.color_lens,
                context: context),
            _box(
                title: "Language",
                subtitle: "English",
                leading: Icons.language,
                context: context),
            _box(
                title: "Settings",
                subtitle: "System configurations",
                leading: Icons.settings,
                context: context),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .95,
              height: 60,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.inversePrimary),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)))),
                  onPressed: () {},
                  child: Text(
                    "Button",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface),
                  )),
            )
          ],
        );
      }),
    );
  }

  Widget _box({required title, required subtitle, required leading, context}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      height: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHigh),
      child: ListTile(
        leading: Icon(leading, size: 30),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
