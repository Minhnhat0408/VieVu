import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_privacy_modal.dart';

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
  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: SliverAppBar(
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
                  _tripStatusSnachBar(widget.trip, context),
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
          IconButton(
            icon: const Icon(Icons.settings),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surface),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(TripSettingsPage.routeName,
                  arguments: widget.trip!); // Navigate to settings page
            },
          ),
          const SizedBox(width: 10),
        ],
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        collapsedHeight: 72,
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            bool isCollapsed = constraints.biggest.height <= 170;
            // log(constraints.biggest.height.toString());
            return FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 84, left: 60),
              title: isCollapsed
                  ? const Text(
                      'Thông tin chuyến đi', // Show title when collapsed
                    )
                  : null, // Hide title when expanded
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
                              widget.tripCover ?? widget.trip?.cover ?? "hello",
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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
            color: Theme.of(context).colorScheme.surface, // TabBar background
            child: TabBar(
              controller: widget.tabController,
              tabs: const [
                Tab(
                  text: 'Thông tin',
                  icon: Icon(
                    Icons.info_outline,
                  ),
                ),
                Tab(
                  text: 'Đã lưu',
                  icon: Icon(
                    Icons.favorite_border_outlined,
                  ),
                ),
                Tab(
                    text: 'Lộ trình',
                    icon: Icon(
                      Icons.map_outlined,
                    )),
                Tab(
                    text: 'Công việc',
                    icon: Icon(
                      Icons.checklist,
                    )),
              ],
            ),
          ),
        ),
      ),
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

SnackBar _tripStatusSnachBar(Trip? trip, BuildContext context) {
  return SnackBar(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          trip != null && trip.isPublished ? Icons.public : Icons.lock,
          color: Colors.black,
        ),
        Text(
          trip != null && trip.isPublished
              ? 'Chuyến đi đang ở chế độ công khai'
              : 'Chuyến đi đang ở chế độ riêng tư',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            // check if trip contains any  null attributes
            if (trip != null) {
              final a = missingInfoMessage(trip);
              if (a.isNotEmpty) {
                showSnackbar(context, a, SnackBarState.warning);
                return;
              } else {
                displayModal(
                    context, TripPrivacyModal(trip: trip), null, false);
              }
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
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
