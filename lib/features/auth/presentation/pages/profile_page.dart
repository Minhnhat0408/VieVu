import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:vievu/features/auth/presentation/pages/edit_profile.dart';
import 'package:vievu/features/auth/presentation/widget/user_rating_modal.dart';
import 'package:vievu/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vievu/features/chat/presentation/pages/chat_details_page.dart';

class ProfilePage extends StatefulWidget {
  final String id;
  const ProfilePage({
    super.key,
    required this.id,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool _isMe = false;
  @override
  void initState() {
    super.initState();
    // user = context.read<AppUserCubit>().state.user;
    final currentUser =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    if (currentUser.id == widget.id) {
      _isMe = true;
    }
    context.read<ProfileBloc>().add(GetProfile(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoadedSuccess) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailsPage(chat: state.chat);
          }));
        }
        if (state is ChatInsertSuccess) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatDetailsPage(chat: state.chat);
          }));
        }
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadedSuccess) {
            user = state.user;
          }

          if (state is ProfileUpdateSuccess) {
            user = state.user;
          }
        },
        builder: (context, state) {
          return CustomAppbar(
            floatingActionButton: _isMe
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditProfilePage(user: user!);
                      }));
                    },
                    child: const Icon(Icons.edit),
                  )
                : null,
            appBarTitle: user != null
                ? "${user?.lastName} ${user?.firstName} ${user?.gender != null ? user!.gender == "Nam" ? "♂️" : "♀️" : ""}"
                : 'Hồ sơ',
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  final link = 'vntravelcompanion://app/profile/${user?.id}';
                  Clipboard.setData(ClipboardData(text: link));
                  showSnackbar(
                      context, 'Đã sao chép liên kết chuyến đi!', 'success');
                },
                icon: const Icon(Icons.share),
              ),
            ],
            body: state is ProfileLoading
                ? const Center(child: CircularProgressIndicator())
                : user == null
                    ? const Center(child: Text('Không tìm thấy người dùng'))
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          CachedNetworkImage(
                            imageUrl: user?.avatarUrl ?? '',
                            imageBuilder: (context, imageProvider) => Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // Change this to your desired border color
                                  width: 2, // Adjust the border thickness
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage: imageProvider,
                              ),
                            ),
                            cacheManager: CacheManager(
                              Config(
                                user?.avatarUrl ?? "",
                                stalePeriod: const Duration(seconds: 10),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                              radius: 70,
                              child: Icon(
                                Icons.person,
                                size: 70,
                              ), // Change this to your desired border color
                            ),
                            fit: BoxFit.cover,
                            width: 140,
                            height: 140,
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${user?.tripCount} ',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            Icons.card_travel,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )
                                        ],
                                      ),
                                      const Text('Chuyến đi'),
                                    ],
                                  ),
                                ),
                                const VerticalDivider(
                                  thickness: 2,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    displayModal(
                                        context,
                                        UserRatingModal(
                                          userId: user!.id,
                                        ),
                                        null,
                                        false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              // set precision to 1 decimal

                                              "${user?.avgRating.toStringAsFixed(1) ?? 0} ",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            )
                                          ],
                                        ),
                                        Text('${user?.ratingCount} đánh giá'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!_isMe)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ChatBloc>().add(GetSingleChat(
                                          userId: user!.id,
                                        ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Nhắn tin',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(

                                    // padding: const EdgeInsets.symmetric(
                                    //     horizontal: 20, vertical: 10),
                                    onPressed: () async {
                                      if (user?.phoneNumber == null) {
                                        return;
                                      }
                                      final Uri callUri =
                                          Uri.parse('tel:${user!.phoneNumber}');
                                      if (await canLaunchUrl(callUri)) {
                                        await launchUrl(callUri);
                                      } else {
                                        throw 'Could not launch $callUri';
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.phone,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )),
                              ],
                            ),
                          Card.outlined(
                            borderOnForeground: true,
                            // shadowColor: Theme.of(context).colorScheme.surface,

                            // color: Theme.of(context).colorScheme.primaryContainer,
                            margin: const EdgeInsets.all(20),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'Thông tin cá nhân',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        user?.city ?? 'Chưa có thông tin',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.alternate_email,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        user?.email ?? 'Chưa có thông tin',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    user?.bio != null
                                        ? "\"${user?.bio} \""
                                        : "Chưa có thông tin",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
          );
        },
      ),
    );
  }
}
