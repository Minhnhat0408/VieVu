import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_info_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailPage extends StatefulWidget {
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
              child: NestedScrollView(
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
                                        Theme.of(context).colorScheme.surface),
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
                              icon: Icon(
                                trip != null && trip!.isPublished
                                    ? Icons.public
                                    : Icons.lock,
                                color: Colors.black,
                              ),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(trip !=
                                            null &&
                                        trip!.isPublished
                                    ? const Color.fromARGB(255, 91, 218, 95)
                                    : const Color.fromARGB(255, 255, 138, 130)),
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.surface),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TripSettingsPage(),
                                  ),
                                );
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
                                titlePadding:
                                    const EdgeInsets.only(bottom: 84, left: 60),
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
                                            padding: const EdgeInsets.fromLTRB(
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                if (widget
                                                    .trip.locations.isNotEmpty)
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
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          trip!.locations
                                                              .join(' - '),
                                                          style:
                                                              const TextStyle(
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
            );
          },
        ),
      ),
    );
  }
}
