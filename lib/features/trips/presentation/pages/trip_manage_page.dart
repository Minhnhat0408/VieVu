import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/constants/trip_filters.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/add_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_small_item.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/settings/trip_status_modal.dart';

class TripManagePage extends StatefulWidget {
  const TripManagePage({super.key});

  @override
  State<TripManagePage> createState() => _TripManagePageState();
}

class _TripManagePageState extends State<TripManagePage> {
  final PagingController<int, Trip> _pagingController =
      PagingController(firstPageKey: 0);
  late ScrollController _scrollController;
  final tripName = TextEditingController();
  TripStatus? _status;
  bool? _visibility;
  bool _haveTrip = false;
  final pageSize = 10;
  int totalRecordCount = 0;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context
        .read<TripBloc>()
        .add(GetCurrentUserTrips(userId: userId, limit: pageSize, offset: 0));
    _pagingController.addPageRequestListener((pageKey) {
      context.read<TripBloc>().add(GetCurrentUserTrips(
          userId: userId,
          status: _status?.value,
          isPublished: _visibility,
          limit: pageSize - 1,
          offset: pageKey));
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // tripName.dispose();\

    super.dispose();
    _scrollController.dispose();
    _pagingController.dispose();
  }

  List<String> options = [
    'Trạng thái',
    'Phạm vi hiển thị',
  ];

  String _convertFilterString(int index) {
    if (index == 0) {
      return _status != null ? _status!.label : options[index];
    } else {
      return _visibility != null
          ? _visibility == true
              ? 'Công khai'
              : 'Riêng tư'
          : options[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chuyến đi của bạn'), actions: [
        IconButton(
          icon: const Icon(Icons.add_location_alt_outlined, size: 28),
          onPressed: () {
            displayModal(
                context,
                BlocProvider.value(
                  value: context.read<TripBloc>(),
                  child: const AddTripModal(),
                ),
                null,
                false);
          },
        ),
        const SizedBox(width: 10),
      ]),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripLoadedSuccess) {
            if (_status == null &&
                _visibility == null &&
                state.trips.isNotEmpty) {
              setState(() {
                _haveTrip = true;
              });
            }

            totalRecordCount += state.trips.length;
            log(state.trips.toString());
            final next = totalRecordCount;
            final isLastPage = state.trips.length < pageSize;
            if (isLastPage) {
              _pagingController.appendLastPage(state.trips);
            } else {
              _pagingController.appendPage(state.trips, next);
            }
          }
          if (state is TripActionSuccess) {
            final currentList = _pagingController.itemList ?? [];

            // Create a new list with the new item at the first position
            //check if the trip is already in the list
            if (currentList
                    .indexWhere((element) => element.id == state.trip.id) !=
                -1) {
              currentList.removeWhere((element) => element.id == state.trip.id);
            }
            final updatedList = [state.trip, ...currentList];

            // Update the PagingController's itemList
            _pagingController.itemList = updatedList;
          }

          if (state is TripDeletedSuccess) {
            totalRecordCount = 0;
            _pagingController.refresh();
          }
        },
        builder: (context, state) {
          return _haveTrip
              ? NestedScrollView(
                  controller: _scrollController,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                                      } else {
                                        setState(() {
                                          if (_visibility == null) {
                                            _visibility = true;
                                          } else if (_visibility != null &&
                                              _visibility == true) {
                                            _visibility = false;
                                          } else {
                                            _visibility = null;
                                          }
                                        });
                                        totalRecordCount = 0;
                                        _pagingController.refresh();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width:
                                            ((_status != null && index == 0) ||
                                                    (_visibility != null &&
                                                        index == 1))
                                                ? 2.0
                                                : 1.0, // Thicker border
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_convertFilterString(index),
                                            style: TextStyle(
                                                fontWeight: ((_status != null &&
                                                            index == 0) ||
                                                        (_visibility != null &&
                                                            index == 1))
                                                    ? FontWeight.bold
                                                    : FontWeight.normal)),
                                        const SizedBox(width: 8),
                                        if (index == 0)
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
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 70),
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Trip>(
                        itemBuilder: (context, item, index) {
                          return TripSmallItem(
                            trip: item,
                          );
                        },
                        firstPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        newPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        noItemsFoundIndicatorBuilder: (_) => const Center(
                            child: Text('Không có chuyến đi nào.')),
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
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'Bắt đầu tạo chuyến đi đầu tiên của bạn',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Tự xây dựng các chuyến đi để bắt đầu hành trình của bạn với các thành viên khác.',
                        style: TextStyle(
                          // italics
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Badge(
                            label: const FaIcon(
                                FontAwesomeIcons.heartCirclePlus,
                                size: 20),
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.all(10),
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            // Use Flexible or Expanded here

                            child: Text(
                              'Lưu các địa điểm, nhà hàng, khách sạn bạn quan tâm',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Badge(
                            label: const FaIcon(FontAwesomeIcons.mapLocationDot,
                                size: 20),
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.all(10),
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            // Use Flexible or Expanded here

                            child: Text(
                              'Xem bản đồ trực quan của chuyến đi bạn đã lên kế hoạch',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Badge(
                            label: const FaIcon(FontAwesomeIcons.clipboardList,
                                size: 20),
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.all(10),
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            // Use Flexible or Expanded here

                            child: Text(
                              'Lên lịch trình và danh sách công việc cần làm dễ dàng hơn',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Badge(
                            label: const FaIcon(FontAwesomeIcons.solidComments,
                                size: 20),
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.all(10),
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            // Use Flexible or Expanded here

                            child: Text(
                              'Cùng thảo luận với các thành viên khác về chuyến đi để lên kế hoạch tốt nhất',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Badge(
                            label: const FaIcon(FontAwesomeIcons.peopleGroup,
                                size: 20),
                            alignment: Alignment.center,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.all(10),
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            // Use Flexible or Expanded here

                            child: Text(
                              'Chia sẻ trải nghiệm và chuyến đi của bạn với cộng đồng',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            displayModal(
                                context,
                                BlocProvider.value(
                                  value: context.read<TripBloc>(),
                                  child: const AddTripModal(),
                                ),
                                null,
                                false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text('Tạo chuyến đi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Reset the PagingController and reload the trips
    _pagingController.refresh();
    totalRecordCount = 0;
  }
}
