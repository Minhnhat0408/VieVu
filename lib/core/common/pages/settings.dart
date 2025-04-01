import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:vievu/core/theme/theme_provider.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vievu/features/auth/presentation/pages/profile_page.dart';
import 'package:vievu/features/notifications/presentation/pages/notification_page.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class SettingsPage extends StatelessWidget {
  final int unreadCount;

  const SettingsPage({super.key, required this.unreadCount});

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
                  const SizedBox(
                    height: 20,
                  ),
                  ...optionLists.entries.map(
                    (entry) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            minVerticalPadding: 16,
                            leading: entry.key == "Thông báo"
                                ? Stack(
                                    children: [
                                      entry.value,
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 10,
                                            child: Text(
                                              '$unreadCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : entry.value,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              if (entry.key == 'Hồ sơ') {
                                final userId = (context
                                        .read<AppUserCubit>()
                                        .state as AppUserLoggedIn)
                                    .user
                                    .id;

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                      id: userId,
                                    ),
                                  ),
                                );
                              } else if (entry.key == 'Thông báo') {
                                // Navigator.of(context)
                                //     .pushNamed('/notification');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationPage(),
                                  ),
                                );
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
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                            child: Divider(),
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
                  // FloatingActionButton(
                  //   onPressed: sendSimpleNoti,
                  //   child: const Icon(Icons.notifications_active),
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
