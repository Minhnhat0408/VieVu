import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/add_itinerary_options_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/select_saved_service_to_itinerary_modal.dart';

class TripItineraryPage extends StatefulWidget {
  final Trip trip;
  const TripItineraryPage({super.key, required this.trip});

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  List<TripItinerary>? _tripItineraries;
  final List<bool> _expanded = List.generate(6, (index) => false);

  final List<DateTime> _panels = [];
  @override
  void initState() {
    super.initState();

    // add date to _panels
    if (widget.trip.startDate != null && widget.trip.endDate != null) {
      final startDate = widget.trip.startDate!;
      final endDate = widget.trip.endDate!;
      for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
        _panels.add(startDate.add(Duration(days: i)));
      }
    }
    log('panels: $_panels');
    setState(() {});
    if (context.read<TripItineraryBloc>().state is TripItineraryLoadedSuccess) {
      final state =
          context.read<TripItineraryBloc>().state as TripItineraryLoadedSuccess;
      setState(() {
        _tripItineraries = state.tripItineraries;
      });
    }
  }

  @override
  void didUpdateWidget(covariant TripItineraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the trip has changed
    if (widget.trip != oldWidget.trip) {
      // Trigger the rebuild
      _panels.clear();
      if (widget.trip.startDate != null && widget.trip.endDate != null) {
        final startDate = widget.trip.startDate!;
        final endDate = widget.trip.endDate!;
        for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
          _panels.add(startDate.add(Duration(days: i)));
        }
      }
      log('panels updated: $_panels');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('trip-itinerary-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverAppBar(
          leading: null,
          primary: false,
          floating: true,
          title: SizedBox(
            height: 40, // Giới hạn chiều cao
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _panels.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceBright,
                    ),
                    child: Text(DateFormat('dd/MM').format(_panels[index])),
                  ),
                );
              },
            ),
          ),
          actions: [
            _panels.isNotEmpty
                ? IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                    ))
                : ElevatedButton(
                    onPressed: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDateRange: null,
                        locale: const Locale('vi', 'VN'),
                      );
                      context.read<TripBloc>().add(UpdateTrip(
                          tripId: widget.trip.id,
                          startDate: picked!.start,
                          endDate: picked.end));
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 5),
                        Text('Thêm ngày'),
                      ],
                    )),
            const SizedBox(width: 20),
          ],
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        BlocConsumer<TripItineraryBloc, TripItineraryState>(
          listener: (context, state) {
            if (state is TripItineraryLoadedSuccess) {
              log(state.tripItineraries.toString());
              setState(() {
                _tripItineraries = state.tripItineraries;
              });
            }

            if (state is TripItineraryAddedSuccess) {
              log(state.tripItinerary.toString());
              setState(() {
                _tripItineraries!.add(state.tripItinerary);
              });
            }
          },
          builder: (context, state) {
            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 70.0),
              sliver: SliverToBoxAdapter(
                child: _tripItineraries != null
                    ? _panels.isNotEmpty
                        ? Column(
                            children: [
                              ExpansionPanelList(
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    log(index.toString());
                                    setState(() {
                                      _expanded[index] = isExpanded;
                                    });
                                  },
                                  expandedHeaderPadding:
                                      const EdgeInsets.all(0),
                                  animationDuration:
                                      const Duration(milliseconds: 1000),
                                  children: [
                                    ..._panels.asMap().entries.map((entry) {
                                      final panel = entry.value;
                                      int index = entry.key;

                                      return ExpansionPanel(
                                        headerBuilder: (BuildContext context,
                                            bool isExpanded) {
                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                            title: Text(
                                                DateFormat("EEE, MMM d, y")
                                                    .format(panel),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          );
                                        },

                                        canTapOnHeader: true,

                                        body: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: _tripItineraries!
                                                      .where((element) =>
                                                          element.time
                                                              .toLocal()
                                                              .toIso8601String()
                                                              .split('T')[0] ==
                                                          panel
                                                              .toLocal()
                                                              .toIso8601String()
                                                              .split('T')[0])
                                                      .isEmpty &&
                                                  _expanded[index]
                                              ? Center(
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 50.0,
                                                          vertical: 28),
                                                      child: Column(
                                                        children: [
                                                          const Text(
                                                            "Thêm các mục đã lưu cho ngày này để hoàn thiện lịch trình",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Container(
                                                            alignment: Alignment
                                                                .center, // Aligns the button to the center
                                                            width: null,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                // Your action here
                                                                final opt =
                                                                    await displayModal(
                                                                        context,
                                                                        const AddItineraryOptionsModal(),
                                                                        null,
                                                                        false);

                                                                if (opt ==
                                                                    'select_saved') {
                                                                  context
                                                                      .read<
                                                                          SavedServiceBloc>()
                                                                      .add(
                                                                          GetSavedServices(
                                                                        tripId: widget
                                                                            .trip
                                                                            .id,
                                                                      ));

                                                                  displayModal(
                                                                      context,
                                                                      SelectSavedServiceToItineraryModal(
                                                                          tripId: widget
                                                                              .trip
                                                                              .id,
                                                                          time:
                                                                              panel),
                                                                      null,
                                                                      true);
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Thêm'),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                )
                                              : FixedTimeline.tileBuilder(
                                                  theme: TimelineThemeData(
                                                    nodePosition: 0,
                                                    color:
                                                        const Color(0xff989898),
                                                    indicatorTheme:
                                                        const IndicatorThemeData(
                                                      position: 0,
                                                      size: 20.0,
                                                    ),
                                                    connectorTheme:
                                                        const ConnectorThemeData(
                                                      thickness: 2.5,
                                                    ),
                                                  ),
                                                  builder: TimelineTileBuilder
                                                      .connected(
                                                    connectionDirection:
                                                        ConnectionDirection
                                                            .before,
                                                    contentsBuilder:
                                                        (context, index) =>
                                                            Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              40.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                            width: 2),
                                                      ),
                                                      child: Text(
                                                          'Timeline Event $index'),
                                                    ),
                                                    itemCount: 10,
                                                    indicatorBuilder:
                                                        (_, index) {
                                                      return const OutlinedDotIndicator(
                                                        color:
                                                            Color(0xff66c97f),
                                                        size: 32.0,
                                                        borderWidth: 2,
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 20.0,
                                                        ),
                                                      );
                                                    },
                                                    connectorBuilder: (_, index,
                                                            ___) =>
                                                        const DashedLineConnector(
                                                            gap: 5,
                                                            thickness: 2,
                                                            dash: 1,
                                                            color: Color(
                                                                0xff66c97f)),
                                                  ),
                                                ),
                                        ),

                                        isExpanded: _expanded[
                                            index], // Use the correct index
                                      );
                                    }),
                                  ])
                            ],
                          )
                        : Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 60.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 80,
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 100,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const Text(
                                    'Thêm ngày đi để xem lịch trình để sắp xếp các mục đã lưu thành một hành trình',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 80.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget _buildTimelineTile(
  //     bool isFirst, TripItinerary item, String time, bool isLast, int index) {
  //   return TimelineTile(
  //     isFirst: isFirst,
  //     isLast: isLast,
  //     beforeLineStyle: LineStyle(
  //       thickness: 3,
  //       color: Theme.of(context).colorScheme.primaryContainer,
  //     ),
  //     indicatorStyle: IndicatorStyle(
  //       width: 40,
  //       height: 40,
  //       indicator: _IndicatorExample(number: '${index + 1}'),
  //       drawGap: true,
  //       padding: const EdgeInsets.only(right: 8),
  //     ),
  //     endChild: Container(
  //         padding: const EdgeInsets.all(16),
  //         height: 200,
  //         margin: const EdgeInsets.symmetric(vertical: 10),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           border: Border.all(
  //             color: Theme.of(context).colorScheme.primaryContainer,
  //             width: 2,
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             SavedServiceMedCard(service: item.service!, isSelected: false)
  //           ],
  //         )),
  //   );
  // }
}

class _IndicatorExample extends StatelessWidget {
  const _IndicatorExample({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 4,
          ),
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
