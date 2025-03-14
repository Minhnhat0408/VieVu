import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_privacy_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailAppbar extends StatefulWidget {
  final Trip? trip;
  final String? tripCover;
  final TabController tabController;
  final String tripId;
  const TripDetailAppbar({
    super.key,
    required this.tabController,
    required this.trip,
    this.tripCover,
    required this.tripId,
  });

  @override
  State<TripDetailAppbar> createState() => _TripDetailAppbarState();
}

class _TripDetailAppbarState extends State<TripDetailAppbar> {
  TripMember? currentUser;

  @override
  void initState() {
    super.initState();
    if (context.read<CurrentTripMemberInfoCubit>().state
        is CurrentTripMemberInfoLoaded) {
      currentUser = (context.read<CurrentTripMemberInfoCubit>().state
              as CurrentTripMemberInfoLoaded)
          .tripMember;
    }
  }

  bool isCompleted() {
    return widget.trip?.status == 'completed' &&
        widget.tabController.length == 5;
  }

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver:
          BlocConsumer<CurrentTripMemberInfoCubit, CurrentTripMemberInfoState>(
        listener: (context, state) {
          if (state is CurrentTripMemberInfoLoaded) {
            currentUser = state.tripMember;
          }
        },
        builder: (context, state) {
          return SliverAppBar(
            expandedHeight: 350,
            floating: true,
            pinned: true,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 32,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surface),
                    ),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate back
                    },
                  )
                : null,
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      _tripStatusSnachBar(widget.trip),
                    );
                },
                icon: Icon(
                  widget.trip != null && widget.trip!.isPublished
                      ? Icons.public
                      : Icons.lock,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      widget.trip != null && widget.trip!.isPublished
                          ? const Color.fromARGB(255, 91, 218, 95)
                          : const Color.fromARGB(255, 255, 138, 130)),
                ),
              ),
              const SizedBox(width: 10),
              if (currentUser != null)
                IconButton(
                  icon: const Icon(Icons.settings),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surface),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripSettingsPage(
                          trip: widget.trip,
                        ),
                      ),
                    ); // Navigate to settings page
                  },
                ),
              if (currentUser == null &&
                  state is! CurrentTripMemberInfoLoading &&
                  widget.trip?.status != 'completed' &&
                  widget.trip?.status != 'cancelled')
                FilledButton(
                  onPressed: () {
                    final userId =
                        (context.read<AppUserCubit>().state as AppUserLoggedIn)
                            .user
                            .id;
                    context.read<TripMemberBloc>().add(
                          InsertTripMember(
                              tripId: widget.tripId,
                              userId: userId,
                              role: 'member'),
                        );
                  },
                  child: const Text(
                    'Tham gia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
            ],
            toolbarHeight: 50,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            collapsedHeight: 72,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // log(constraints.biggest.height.toString());
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 84, left: 60),
                  background: Padding(
                    padding: const EdgeInsets.only(bottom: 72.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: widget.tripId,
                            child: CachedNetworkImage(
                              imageUrl:
                                  widget.tripCover ?? widget.trip?.cover ?? "",
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                fit: BoxFit.cover,
                              ),
                              cacheManager: CacheManager(
                                Config(
                                  widget.tripCover ??
                                      widget.trip?.cover ??
                                      "hello",
                                  stalePeriod: const Duration(seconds: 10),
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,

                                  // Colors.transparent,
                                  const ColorScheme.dark().surface,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 32),
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min, // Expand based on content
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    widget.trip?.name ?? "Đang tải...",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (widget.trip != null &&
                                      widget.trip!.locations.isNotEmpty)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the start
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.trip!.locations.join(' - '),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color:
                    Theme.of(context).colorScheme.surface, // TabBar background
                child: TabBar(
                  controller: widget.tabController,
                  isScrollable: isCompleted() ? true : false,
                  tabAlignment: isCompleted() ? TabAlignment.start : null,
                  labelPadding: isCompleted()
                      ? null
                      : const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  tabs: [
                    const Tab(
                      text: 'Chi tiết',
                      icon: Icon(
                        Icons.info_outline,
                      ),
                    ),
                    if (isCompleted())
                      const Tab(
                        text: 'Đánh giá',
                        icon: Icon(
                          Icons.insert_comment_outlined,
                        ),
                      ),
                    const Tab(
                      text: 'Mục lưu',
                      icon: Icon(
                        Icons.favorite_border_outlined,
                      ),
                    ),
                    const Tab(
                        text: 'Lộ trình',
                        icon: Icon(
                          Icons.map_outlined,
                        )),
                    const Tab(
                        text: 'Thành viên',
                        icon: Icon(
                          Icons.group_outlined,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SnackBar _tripStatusSnachBar(Trip? trip) {
    log('Current user: ${currentUser?.role}');
    return SnackBar(
      padding: currentUser?.role == 'owner' &&
              trip!.status != 'completed' &&
              trip.status != 'cancelled'
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      content: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
              trip != null && trip.isPublished ? Icons.public : Icons.lock,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              trip != null && trip.isPublished
                  ? 'Chuyến đi đang ở chế độ công khai'
                  : 'Chuyến đi đang ở chế độ riêng tư',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          if (currentUser?.role == 'owner' &&
              trip!.status != 'completed' &&
              trip.status != 'cancelled')
            TextButton(
              onPressed: () {
                // check if trip contains any  null attributes
                final a = missingInfoMessage(trip);
                if (a.isNotEmpty) {
                  showSnackbar(context, a, SnackBarState.warning);
                  return;
                } else {
                  displayModal(
                      context, TripPrivacyModal(trip: trip), null, false);
                }
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              ),
              child: const Text(
                'Thay đổi',
                style: TextStyle(
                  color: Colors.black,

                  decorationColor: Colors.black,
                  decoration: TextDecoration.underline, // Underline text
                ),
              ),
            ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      behavior: SnackBarBehavior.floating,
      backgroundColor: trip != null && trip.isPublished
          ? const Color.fromARGB(255, 91, 218, 95)
          : const Color.fromARGB(255, 255, 138, 130),
    );
  }
}

String missingInfoMessage(Trip trip) {
  if (trip.locations.isEmpty) {
    return 'Vui lòng thêm địa điểm cho chuyến đi trước khi công khai';
  }
  if (trip.cover == null) {
    return 'Vui lòng thêm ảnh bìa cho chuyến đi trước  khi công khai';
  }

  if (trip.description == null) {
    return 'Vui lòng thêm mô tả cho chuyến đi trước  khi công khai';
  }

  if (trip.startDate == null || trip.endDate == null) {
    return 'Vui lòng thêm thời gian cho chuyến đi trước  khi công khai';
  }

  if (trip.maxMember == null) {
    return 'Vui lòng thêm số lượng thành viên tối đa cho chuyến đi trước khi công khai';
  }

  if (trip.transports == null) {
    return 'Vui lòng thêm phương tiện di chuyển cho chuyến đi trước  khi công khai';
  }

  return '';
}
