import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:vn_travel_companion/core/utils/conversions.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/add_custom_place_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/add_itinerary_options_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/edit_trip_itinerary_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/map_view_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/select_saved_service_to_itinerary_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/timeline_item.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class TripItineraryPage extends StatefulWidget {
  final Trip trip;
  final TripMember? currentUser;
  const TripItineraryPage({super.key, required this.trip, this.currentUser});

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  List<TripItinerary>? _tripItineraries;
  List<bool> _expanded = [];

  final List<DateTime> _panels = [];
  final List<DateTime> _selectedDates = [];
  @override
  void initState() {
    super.initState();
    // add date to _panels
    if (widget.trip.startDate != null && widget.trip.endDate != null) {
      final startDate = widget.trip.startDate!;
      final endDate = widget.trip.endDate!;
      for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
        _panels.add(startDate.add(Duration(days: i)));
        _expanded.add(false);
      }
    }

    if (context.read<TripItineraryBloc>().state is TripItineraryLoadedSuccess) {
      final state =
          context.read<TripItineraryBloc>().state as TripItineraryLoadedSuccess;
      setState(() {
        _tripItineraries = state.tripItineraries;
      });

      // set panel expanded if there is itinerary
      for (var i = 0; i < _panels.length; i++) {
        final panel = _panels[i];
        final itineraries = _tripItineraries!.where((element) {
          return element.time.toIso8601String().split('T')[0] ==
              panel.toIso8601String().split('T')[0];
        }).toList();
        if (itineraries.isNotEmpty) {
          _expanded[i] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripActionSuccess) {
          if (state.trip.startDate != null && state.trip.endDate != null) {
            final startDate = state.trip.startDate!;
            final endDate = state.trip.endDate!;
            _panels.clear();
            _expanded.clear();
            for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
              _panels.add(startDate.add(Duration(days: i)));
              _expanded.add(false);
            }
          }
          setState(() {});
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            _tripItineraries = null;
            context
                .read<TripItineraryBloc>()
                .add(GetTripItineraries(tripId: widget.trip.id));
          },
          child: CustomScrollView(
            key: const PageStorageKey('trip-itinerary-page'),
            slivers: [
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
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
                          onPressed: () {
                            // Toggle selection
                            if (_selectedDates.contains(_panels[index])) {
                              _selectedDates.remove(_panels[index]);
                            } else {
                              _selectedDates.add(_panels[index]);
                            }
                            if (_selectedDates.isEmpty) {
                              _expanded = List.filled(_panels.length, false);
                              for (var i = 0; i < _panels.length; i++) {
                                final panel = _panels[i];
                                final itineraries =
                                    _tripItineraries!.where((element) {
                                  return element.time
                                          .toIso8601String()
                                          .split('T')[0] ==
                                      panel.toIso8601String().split('T')[0];
                                }).toList();
                                if (itineraries.isNotEmpty) {
                                  _expanded[i] = true;
                                }
                              }
                            } else {
                              _expanded =
                                  List.filled(_selectedDates.length, true);
                            }

                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceBright,
                            side: BorderSide(
                              color: _selectedDates.contains(_panels[index])
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary // Selected color
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline, // Default color
                              width: 2, // Border width
                            ),
                          ),
                          child: Text(
                            DateFormat('dd/MM').format(_panels[index]),
                            style: TextStyle(
                              color: _selectedDates.contains(_panels[index])
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary // Text color for selected state
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant, // Default text color
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  _panels.isNotEmpty
                      ? widget.currentUser != null
                          ? IconButton(
                              onPressed: widget.currentUser != null &&
                                      widget.currentUser!.role != 'member'
                                  ? () {
                                      displayModal(
                                          context,
                                          EditTripItineraryModal(
                                            panels: _panels,
                                            tripItinerary: _tripItineraries!,
                                          ),
                                          null,
                                          true);
                                    }
                                  : null,
                              style: IconButton.styleFrom(
                                side: BorderSide(
                                    width: 2,
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                              icon: const Icon(Icons.edit, size: 20))
                          : const SizedBox.shrink()
                      : widget.currentUser != null
                          ? ElevatedButton(
                              onPressed: widget.currentUser?.role != 'member'
                                  ? () async {
                                      final DateTimeRange? picked =
                                          await showDateRangePicker(
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
                                    }
                                  : null,
                              child: const Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 5),
                                  Text('Thêm ngày'),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                  const SizedBox(width: 20),
                ],
                pinned: true,
                automaticallyImplyLeading: false,
              ),
              BlocConsumer<TripItineraryBloc, TripItineraryState>(
                listener: (context, state) {
                  if (state is TripItineraryLoadedSuccess) {
                    if (mounted) {
                      setState(() {
                        _tripItineraries = state.tripItineraries;
                        for (var i = 0; i < _panels.length; i++) {
                          final panel = _panels[i];
                          final itineraries =
                              _tripItineraries!.where((element) {
                            return element.time
                                    .toIso8601String()
                                    .split('T')[0] ==
                                panel.toIso8601String().split('T')[0];
                          }).toList();
                          if (itineraries.isNotEmpty) {
                            _expanded[i] = true;
                          }
                        }
                      });
                    }
                  }
                  if (state is TripItineraryAddedSuccess) {
                    log(state.tripItinerary.toString());

                    setState(() {
                      _tripItineraries!.add(state.tripItinerary);
                    });
                  }

                  if (state is TripItineraryUpdatedSuccess) {
                    log(state.tripItinerary.toString());

                    setState(() {
                      // Find the index of the updated itinerary
                      final index = _tripItineraries!.indexWhere(
                          (element) => element.id == state.tripItinerary.id);

                      if (index != -1 &&
                          _tripItineraries![index].time !=
                              state.tripItinerary.time) {
                        // Remove the old itinerary
                        _tripItineraries!.removeAt(index);

                        // Find the correct index to insert the new itinerary
                        int newIndex = _tripItineraries!.indexWhere((element) =>
                            element.time.isAfter(state.tripItinerary.time));

                        if (newIndex == -1) {
                          // Nếu không tìm thấy, thêm vào cuối danh sách
                          _tripItineraries!.add(state.tripItinerary);
                        } else {
                          // Insert vào vị trí phù hợp
                          _tripItineraries!
                              .insert(newIndex, state.tripItinerary);
                        }
                      }
                    });
                  }

                  if (state is TripItineraryDeletedSuccess) {
                    setState(() {
                      _tripItineraries!.removeWhere(
                          (element) => element.id == state.itineraryId);
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
                                          setState(() {
                                            _expanded[index] = isExpanded;
                                          });
                                        },
                                        expandedHeaderPadding:
                                            const EdgeInsets.all(0),
                                        animationDuration:
                                            const Duration(milliseconds: 1000),
                                        children: [
                                          ...(_selectedDates.isNotEmpty
                                                  ? _selectedDates
                                                  : _panels)
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final panel = entry.value;
                                            int index = entry.key;
                                            final List<TripItinerary>
                                                itineraries = _tripItineraries!
                                                    .where((element) {
                                              return element.time
                                                      .toIso8601String()
                                                      .split('T')[0] ==
                                                  panel
                                                      .toIso8601String()
                                                      .split('T')[0];
                                            }).toList();
                                            return ExpansionPanel(
                                              headerBuilder:
                                                  (BuildContext context,
                                                      bool isExpanded) {
                                                return ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                  title: Text(
                                                    DateFormat("EEE, MMM d, y")
                                                        .format(panel),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: FilledButton(
                                                    onPressed: itineraries
                                                            .isNotEmpty
                                                        ? () {
                                                            displayFullScreenModal(
                                                                context,
                                                                MapViewModal(
                                                                  tripItineraries:
                                                                      itineraries,
                                                                  panel: panel,
                                                                ));
                                                          }
                                                        : null,
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.map),
                                                        SizedBox(width: 5),
                                                        Text('Bản đồ'),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              canTapOnHeader: true,
                                              body: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  child: itineraries.isEmpty &&
                                                          _expanded[index]
                                                      ? _emptyItineraryDisplay(
                                                          panel)
                                                      : _itinerariesDisplay(
                                                          itineraries,
                                                          panel,
                                                        )),

                                              isExpanded: _expanded[
                                                  index], // Use the correct index
                                            );
                                          }),
                                        ])
                                  ],
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 60.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 80,
                                        ),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 100,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
          ),
        );
      },
    );
  }

  Widget _emptyItineraryDisplay(DateTime panel) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 28),
          child: Column(
            children: [
              Text(
                widget.currentUser != null
                    ? "Thêm các mục đã lưu cho ngày này để hoàn thiện lịch trình"
                    : "Không có mục nào được thêm vào lịch trình",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              if (widget.currentUser != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
                  ),
                  onPressed: widget.currentUser!.role != 'member'
                      ? () async {
                          // Your action here
                          final opt = await displayModal(context,
                              const AddItineraryOptionsModal(), null, false);

                          if (opt == 'select_saved') {
                            context
                                .read<SavedServiceBloc>()
                                .add(GetSavedServices(
                                  tripId: widget.trip.id,
                                ));

                            displayModal(
                                context,
                                SelectSavedServiceToItineraryModal(
                                    tripId: widget.trip.id, time: panel),
                                null,
                                true);
                          } else {
                            displayFullScreenModal(
                                context,
                                BlocProvider(
                                  create: (context) =>
                                      serviceLocator<LocationInfoCubit>(),
                                  child: AddCustomPlaceModal(
                                    tripId: widget.trip.id,
                                    date: panel,
                                  ),
                                ));
                          }
                        }
                      : null,
                  child: const IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text('Thêm'),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _itinerariesDisplay(List<TripItinerary> itineraries, DateTime panel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: Theme.of(context).colorScheme.outline,
            indicatorTheme: const IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            contentsBuilder: (context, index) => TimelineItem(
              itineraries: itineraries,
              index: index,
              panel: panel,
            ),
            itemCount: itineraries.length,
            indicatorBuilder: (_, index) {
              return OutlinedDotIndicator(
                size: 36.0,
                borderWidth: 2,
                child: Tooltip(
                  message:
                      convertTypeIdToString(itineraries[index].service?.typeId),
                  child: convertTypeIdToIcons(
                      itineraries[index].service?.typeId, 20),
                ),
              );
            },
            connectorBuilder: (_, index, ___) => const DashedLineConnector(
              gap: 5,
              thickness: 2,
              dash: 1,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
          ),
          onPressed: widget.currentUser != null &&
                  widget.currentUser!.role != 'member'
              ? () async {
                  // Your action here
                  final opt = await displayModal(
                      context, const AddItineraryOptionsModal(), null, false);

                  if (opt == 'select_saved') {
                    context.read<SavedServiceBloc>().add(GetSavedServices(
                          tripId: widget.trip.id,
                        ));

                    displayModal(
                        context,
                        SelectSavedServiceToItineraryModal(
                            tripId: widget.trip.id, time: panel),
                        null,
                        true);
                  } else {
                    displayFullScreenModal(
                        context,
                        BlocProvider(
                          create: (context) =>
                              serviceLocator<LocationInfoCubit>(),
                          child: AddCustomPlaceModal(
                            tripId: widget.trip.id,
                            date: panel,
                          ),
                        ));
                  }
                }
              : null,
          child: const IntrinsicWidth(
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                ),
                SizedBox(
                  width: 4,
                ),
                Text('Thêm'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
