import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_info_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailPage extends StatefulWidget {
  static const String routeName = '/trip-detail';
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  Trip? trip;
  @override
  void initState() {
    super.initState();

    trip = widget.trip;

    context.read<TripDetailsCubit>().getTripDetails(tripId: widget.trip.id);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: BlocConsumer<TripDetailsCubit, TripDetailsState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is TripDetailsLoadedSuccess) {
              setState(() {
                trip = state.trip;
              });
            }
            if (state is TripDetailsLoadedFailure) {
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            return BlocListener<TripBloc, TripState>(
              listener: (context, state) {
                // TODO: implement listener

                if (state is TripActionSuccess) {
                  setState(() {
                    trip = state.trip;
                  });
                }
              },
              child: Stack(children: [
                NestedScrollView(
                    floatHeaderSlivers: true,
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(
                            expandedHeight: 350,
                            floating: true,
                            pinned: true,
                            leading: Navigator.canPop(context)
                                ? IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 32,
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context)
                                              .colorScheme
                                              .surface),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Navigate back
                                    },
                                  )
                                : null,
                            actions: [
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        content: Row(
                                          children: [
                                            Icon(
                                              trip != null && trip!.isPublished
                                                  ? Icons.public
                                                  : Icons.lock,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              trip != null && trip!.isPublished
                                                  ? 'Chuyến đi đang ở chế độ công khai'
                                                  : 'Chuyến đi đang ở chế độ riêng tư',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            TextButton(
                                              onPressed: () {
                                                // check if trip contains any  null attributes
                                                if (trip != null) {
                                                  final a =
                                                      missingInfoMessage(trip!);
                                                  if (a.isNotEmpty) {
                                                    showSnackbar(context, a,
                                                        SnackBarState.warning);
                                                    return;
                                                  }
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(4),
                                              ),
                                              child: const Text(
                                                'Thay đổi',
                                                style: TextStyle(
                                                  color: Colors.black,

                                                  decorationColor: Colors.black,
                                                  decoration: TextDecoration
                                                      .underline, // Underline text
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 24),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                            trip != null && trip!.isPublished
                                                ? const Color.fromARGB(
                                                    255, 91, 218, 95)
                                                : const Color.fromARGB(
                                                    255, 255, 138, 130),
                                      ),
                                    );
                                },
                                icon: Icon(
                                  trip != null && trip!.isPublished
                                      ? Icons.public
                                      : Icons.lock,
                                  color: Colors.black,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      trip != null && trip!.isPublished
                                          ? const Color.fromARGB(
                                              255, 91, 218, 95)
                                          : const Color.fromARGB(
                                              255, 255, 138, 130)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.surface),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(TripSettingsPage
                                      .routeName); // Navigate to settings page
                                },
                              ),
                              const SizedBox(width: 10),
                            ],
                            toolbarHeight: 50,
                            scrolledUnderElevation: 0,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            collapsedHeight: 72,
                            flexibleSpace: LayoutBuilder(
                              builder: (context, constraints) {
                                bool isCollapsed =
                                    constraints.biggest.height <= 170;
                                // log(constraints.biggest.height.toString());
                                return FlexibleSpaceBar(
                                  titlePadding: const EdgeInsets.only(
                                      bottom: 84, left: 60),
                                  title: isCollapsed
                                      ? const Text(
                                          'Thông tin chuyến đi', // Show title when collapsed
                                        )
                                      : null, // Hide title when expanded
                                  background: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 72.0),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Hero(
                                            tag: widget.trip.id,
                                            child: CachedNetworkImage(
                                              imageUrl: trip!.cover ?? "",
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                                fit: BoxFit.cover,
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
                                                  const ColorScheme.dark()
                                                      .surface,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 20, 20, 32),
                                              child: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Expand based on content
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    trip!.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  if (widget.trip.locations
                                                      .isNotEmpty)
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start, // Align text to the start
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            trip!.locations
                                                                .join(' - '),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface, // TabBar background
                                child: const TabBar(
                                  tabs: [
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
                        ],
                    body: TabBarView(children: [
                      TripInfoPage(trip: trip!),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Item $index'),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Item $index'),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Item $index'),
                            );
                          },
                        ),
                      ),
                    ])),
                Positioned.fill(
                    child: CircularMenu(
                        alignment: const Alignment(0.95, 0.85),
                        startingAngleInRadian:
                            3.14, // Example: 180 degrees (π radians)
                        endingAngleInRadian:
                            3.14 * 2, // Example: 360 degrees (2π radians)
                        items: [
                      CircularMenuItem(
                          icon: Icons.home,
                          onTap: () {
                            // callback
                          }),
                      CircularMenuItem(
                          icon: Icons.search,
                          onTap: () {
                            //callback
                          }),
                      CircularMenuItem(
                          icon: Icons.pages,
                          onTap: () {
                            //callback
                          }),
                    ]))
              ]),
            );
          },
        ),
      ),
    );
  }
}
