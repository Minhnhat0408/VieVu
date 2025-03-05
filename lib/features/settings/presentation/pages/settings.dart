import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/theme/theme_provider.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class SettingsPage extends StatelessWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const SettingsPage());
  }

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, Icon> optionLists = {
      'Hồ sơ': const Icon(
        Icons.person_outline,
        size: 30,
      ),
      'Thông báo': const Icon(
        Icons.notifications_outlined,
        size: 30,
      ),
      'Phiên bản': const Icon(
        Icons.info_outline,
        size: 30,
      ),
      'Hỗ trợ': const Icon(
        Icons.help_outline,
        size: 30,
      ),

      // 'Báo cáo': 'Báo cáo chuyến đi không phù hợp',
    };
    return CustomAppbar(
      appBarTitle: 'Tài khoản',
      actions: [
        Consumer<ThemeProvider>(builder: (context, notifier, child) {
          return IconButton(
              onPressed: () {
                context.read<ThemeProvider>().themeOnChanged();
              },
              icon: Icon(
                  notifier.isDarkMode ? Icons.dark_mode : Icons.light_mode));
        }),
        Consumer<ThemeProvider>(builder: (context, notifier, child) {
          return IconButton(
            onPressed: () {
              context.read<ThemeProvider>().themeSystemOnChanged();
            },
            icon: Icon(
              Icons.computer,
              color: notifier.isSystemOn ? Colors.green : Colors.grey,
            ),
          );
        })
      ],
      body: Consumer<ThemeProvider>(
        builder: (context, notifier, child) {
          return BlocConsumer<AppUserCubit, AppUserState>(
            listener: (context, state) {
              if (state is AppUserNotLoggedIn) {
                showSnackbar(context, 'Đăng xuất thành công');
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  ...optionLists.entries.map(
                    (entry) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                            minVerticalPadding: 16,
                            leading: entry.value,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              if (entry.key == 'Hồ sơ') {
                                // Navigator.of(context).pushNamed('/profile');
                              } else if (entry.key == 'Thông báo') {
                                // Navigator.of(context)
                                //     .pushNamed('/notification');
                              } else if (entry.key == 'Phiên bản') {
                                showAboutDialog(
                                    context: context,
                                    applicationName: 'Vietnam Travel Companion',
                                    applicationVersion: '1.0.0',
                                    applicationIcon: ImageIcon(
                                      const AssetImage(
                                        'assets/images/icon_logo.png',
                                      ),
                                      size: 50,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    applicationLegalese:
                                        '© 2021 Travel Companion');
                              } else if (entry.key == 'Hỗ trợ') {
                                // Navigator.of(context).pushNamed('/support');
                              }
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Divider(
                              thickness: 1,
                              height: 2,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * .95,
                    height: 60,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.primaryContainer),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)))),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogout());
                          context
                              .read<PreferencesBloc>()
                              .add(UserPreferenceSignOut());
                        },
                        child: Text(
                          "Đăng xuất",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                        )),
                  ),
                  // OpenContainer(
                  //   closedBuilder: (context, VoidCallback openContainer) {
                  //     return ElevatedButton(
                  //         onPressed: openContainer,
                  //         style: ElevatedButton.styleFrom(
                  //           elevation: 0,
                  //         ),
                  //         child: const Text('Test Animation'));
                  //   },
                  //   closedElevation: 0,
                  //   transitionDuration: const Duration(milliseconds: 2000),
                  //   closedShape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(50)),
                  //   openBuilder: (context, _) => const SettingsPage(),
                  // )
                ],
              );
            },
          );
        },
      ),
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
