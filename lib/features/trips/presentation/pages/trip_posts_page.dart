import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/constants/transport_options.dart';
import 'package:vn_travel_companion/core/constants/trip_filters.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';
import 'package:vn_travel_companion/features/search/domain/entities/home_search_result.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/home_search_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_status_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_transports_modal.dart';
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
    'Phương tiện',
  ];
  final PagingController<int, Trip> _pagingController =
      PagingController(firstPageKey: 0);
  void onSuffixTap() {
    textController.clear();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      totalRecordCount = 0;
      _pagingController.refresh();
    }
  }

  List<TransportOption> _currentTransports = [];

  DateTimeRange? selectedDateRange;
  TripStatus? _status;
  List<HomeSearchResult> searchResult = [];
  final pageSize = 10;
  int totalRecordCount = 0;
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context
        .read<TripBloc>()
        .add(GetCurrentUserTrips(userId: userId, limit: pageSize, offset: 0));
    _pagingController.addPageRequestListener((pageKey) {
      context.read<TripBloc>().add(GetTrips(
          status: _status?.value,
          startDate: selectedDateRange?.start,
          endDate: selectedDateRange?.end,
          transports: _currentTransports.isEmpty
              ? null
              : _currentTransports.map((e) => e.value).toList(),
          limit: pageSize - 1,
          offset: pageKey));
    });
  }

  String _convertFilterString(int index) {
    if (index == 0) {
      return _status != null ? _status!.label : options[index];
    } else {
      return options[index];
    }
  }

  Future<void> _onRefresh() async {
    // Reset the PagingController and reload the trips
    _pagingController.refresh();
    totalRecordCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocConsumer<SearchBloc, SearchState>(
            listener: (context, state) {
              if (state is SearchHomeSuccess) {
                setState(() {
                  searchResult = state.results;
                });
              }
            },
            builder: (context, state) {
              return Hero(
                tag: 'homeSearch',
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeSearchPage(),
                      ),
                    );
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
              );
            },
          ),
          const SizedBox(width: 14),
        ],
        titleSpacing: 14,
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  id: (context.read<AppUserCubit>().state as AppUserLoggedIn)
                      .user
                      .id,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      (context.read<AppUserCubit>().state as AppUserLoggedIn)
                              .user
                              .avatarUrl ??
                          '',
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 20,
                    backgroundImage: imageProvider,
                  ),
                  height: 40,
                  width: 40,
                  placeholder: (context, url) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
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
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripPostsLoadedSuccess) {
            // if (_status == null &&
            //     _visibility == null &&
            //     state.trips.isNotEmpty) {
            //   setState(() {
            //     _haveTrip = true;
            //   });
            // }

            totalRecordCount += state.trips.length;
            // log(state.trips.toString());
            final next = totalRecordCount;
            final isLastPage = state.trips.length < pageSize;
            if (isLastPage) {
              _pagingController.appendLastPage(state.trips);
            } else {
              _pagingController.appendPage(state.trips, next);
            }
          }
        },
        builder: (context, state) {
          return NestedScrollView(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 6),
                    child: Row(
                      children: List.generate(
                        options.length, // Number of buttons
                        (index) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: OutlinedButton(
                              onPressed: () {
                                if (index == 0) {
                                  displayModal(
                                      context,
                                      TripStatusModal(
                                        currentStatus: _status,
                                        onStatusChanged: (newStatus) {
                                          setState(() {
                                            _status = newStatus;
                                          });
                                          totalRecordCount = 0;
                                          _pagingController.refresh();
                                        },
                                      ),
                                      null,
                                      false);
                                } else if (index == 1) {
                                  _selectDateRange(context);
                                } else if (index == 2) {
                                  displayModal(
                                      context,
                                      TripTransportsModal(
                                        currentTransports: _currentTransports,
                                        onTransportsChanged: (newTransports) {
                                          setState(() {
                                            _currentTransports = newTransports;
                                          });
                                          log(_currentTransports.toString());
                                          totalRecordCount = 0;
                                          _pagingController.refresh();
                                        },
                                      ),
                                      null,
                                      false);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: ((_status != null && index == 0) ||
                                          (selectedDateRange != null &&
                                              index == 1) ||
                                          (_currentTransports.isNotEmpty &&
                                              index == 2))
                                      ? 2.0
                                      : 1.0, // Thicker border
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      index == 1
                                          ? selectedDateRange != null
                                              ? "${DateFormat('dd/MM/yyyy').format(selectedDateRange?.start ?? DateTime.now())}-${DateFormat('dd/MM/yyyy').format(selectedDateRange?.end ?? DateTime.now())}"
                                              : options[index]
                                          : _convertFilterString(index),
                                      style: TextStyle(
                                          fontWeight: ((_status != null &&
                                                      index == 0) ||
                                                  (selectedDateRange != null &&
                                                      index == 1) ||
                                                  (_currentTransports
                                                          .isNotEmpty &&
                                                      index == 2))
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
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
            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: PagedListView<int, Trip>(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 70),
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Trip>(
                  itemBuilder: (context, item, index) {
                    return TripPostItem(
                      trip: item,
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  noItemsFoundIndicatorBuilder: (_) =>
                      const Center(child: Text('Không có chuyến đi nào.')),
                  newPageErrorIndicatorBuilder: (context) => Center(
                    child: TextButton(
                      onPressed: () =>
                          _pagingController.retryLastFailedRequest(),
                      child: const Text('Thử lại'),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
