import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    // user = context.read<AppUserCubit>().state.user;
    final currentUser =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    if (currentUser.id == widget.id) {
      user = currentUser;
    } else {
      // user = context.read<AppUserCubit>().getUserById(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: "${user?.lastName} ${user?.firstName}",
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/edit');
          },
          icon: const Icon(Icons.edit),
        ),
      ],
      body: Column(
        children: [
          const SizedBox(height: 20),
          CachedNetworkImage(
            imageUrl: user?.avatarUrl ?? '',
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 50,
              backgroundImage: imageProvider,
            ),
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              Icon(
                Icons.location_on,
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                "Hà Nội",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            '10 ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.card_travel,
                            color: Theme.of(context).colorScheme.primary,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '10 ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          )
                        ],
                      ),
                      Text('Đánh giá'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Theo dõi',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(

                  // padding: const EdgeInsets.symmetric(
                  //     horizontal: 20, vertical: 10),
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.phone,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
