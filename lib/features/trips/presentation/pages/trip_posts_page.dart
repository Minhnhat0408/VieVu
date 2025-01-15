import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_post_item.dart';

class TripPostsPage extends StatefulWidget {
  const TripPostsPage({super.key});

  @override
  State<TripPostsPage> createState() => _TripPostsPageState();
}

class _TripPostsPageState extends State<TripPostsPage> {
  final textController = TextEditingController();
  int toggle = 0;
  List<String> options = [
    'Trạng thái',
    'Thời gian',
    'Điểm đến',
    'Phương tiện',
  ];
  void onSuffixTap() {
    textController.clear();
  }

  void onSubmitted(String value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          SearchAnchor(
            builder: (context, controller) => IconButton(
              onPressed: () {
                controller.openView();
              },
              icon: const Icon(Icons.search),
              iconSize: 24,
              constraints: const BoxConstraints(
                minWidth: 46, // Set the minimum width of the button
                minHeight: 46, // Set the minimum height of the button
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            suggestionsBuilder: (context, controller) => [
              ListTile(
                title: const Text('Suggestion 1'),
                onTap: () {
                  controller.text = 'Suggestion 1';
                },
              ),
              ListTile(
                title: const Text('Suggestion 2'),
                onTap: () {
                  controller.text = 'Suggestion 2';
                },
              ),
            ],
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            iconSize: 24,
            constraints: const BoxConstraints(
              minWidth: 46, // Set the minimum width of the button
              minHeight: 46, // Set the minimum height of the button
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(width: 14),
        ],
        titleSpacing: 14,
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  (context.read<AppUserCubit>().state as AppUserLoggedIn)
                          .user
                          .avatarUrl ??
                      '',
                ),
              ),
              const SizedBox(width: 10),
              Text(
                (context.read<AppUserCubit>().state as AppUserLoggedIn)
                    .user
                    .firstName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            leading: null,
            automaticallyImplyLeading: false,
            snap: true,
            scrolledUnderElevation: 0,
            flexibleSpace: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
                child: Row(
                  children: List.generate(
                    options.length, // Number of buttons
                    (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            // backgroundColor:
                            //     Theme.of(context).colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                options[index],
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => const TripPostItem(),
        ),
      ),
    );
  }
}
