import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/add_saved_services_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/saved_service_big_card.dart';

class TripSavedServicesPage extends StatefulWidget {
  final Trip trip;
  const TripSavedServicesPage({super.key, required this.trip});

  @override
  State<TripSavedServicesPage> createState() => _TripSavedServicesPageState();
}

class _TripSavedServicesPageState extends State<TripSavedServicesPage> {
  final Map<String, int> _panels = {
    "Địa điểm tham quan": 2,
    "Đồ ăn & đồ uống": 1,
    "Địa điểm lưu trú": 4,
    "Sự kiện & giải trí": 5,
    "Điểm đến du lịch": 0,
  };

  final List<bool> _expanded = List.generate(6, (index) => false);
  List<SavedService>? _savedServices;
  @override
  void initState() {
    super.initState();
    if (context.read<SavedServiceBloc>().state is SavedServicesLoadedSuccess) {
      loadSavedServices(context.read<SavedServiceBloc>().state);
    }
  }

  void loadSavedServices(state) {
    for (int i in [0, 1, 2, 4, 5]) {
      if (state.savedServices.any((item) => item.typeId == i)) {
        setState(() {
          // Get the actual index
          _expanded[i] = true;
        });
      }
    }

    setState(() {
      _savedServices = state.savedServices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        key: const PageStorageKey('trip-saved-services-page'),
        slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverAppBar(
            leading: null,
            primary: false,
            floating: true,
            title: Text(
                "${_savedServices != null ? _savedServices!.length : widget.trip.serviceCount} mục đã lưu",
                style: const TextStyle(fontSize: 16)),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    // showDialog
                    displayFullScreenModal(
                        context, AddSavedServicesPage(trip: widget.trip));
                  },
                  child: const Text('Thêm')),
              const SizedBox(width: 20),
            ],
            pinned: true,
            automaticallyImplyLeading: false,
          ),
          BlocConsumer<SavedServiceBloc, SavedServiceState>(
            listener: (context, state) {
              // TODO: implement listener

              if (state is SavedServicesLoadedSuccess) {
                loadSavedServices(state);
              }

              if (state is SavedServiceActionSucess) {
                if (state.tripId == widget.trip.id) {
                  setState(() {
                    _savedServices!.add(state.savedService);
                  });

                  // check if the panel is expanded
                  if (!_expanded[state.savedService.typeId]) {
                    setState(() {
                      _expanded[state.savedService.typeId] = true;
                    });
                  }
                }
              }

              if (state is SavedServiceDeleteSuccess) {
                if (state.tripId == widget.trip.id) {
                  setState(() {
                    // Remove the deleted service from the list
                    _savedServices!
                        .removeWhere((item) => item.id == state.linkId);
                  });
                }
              }
            },
            builder: (context, state) {
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 70.0),
                sliver: SliverToBoxAdapter(
                  child: widget.trip.serviceCount > 0
                      ? _savedServices != null
                          ? Column(
                              children: [
                                ExpansionPanelList(
                                    expansionCallback:
                                        (int index, bool isExpanded) {
                                      log(index.toString());
                                      setState(() {
                                        final actualIndex =
                                            _panels.values.toList()[
                                                index]; // Get the actual index
                                        _expanded[actualIndex] = isExpanded;
                                      });
                                    },
                                    expandedHeaderPadding:
                                        const EdgeInsets.all(0),
                                    animationDuration:
                                        const Duration(milliseconds: 1000),
                                    children: [
                                      ..._panels.entries.map((entry) {
                                        String panel = entry.key;
                                        int index = entry
                                            .value; // Assuming _panels is a List<String>

                                        return ExpansionPanel(
                                          headerBuilder: (BuildContext context,
                                              bool isExpanded) {
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              title: Text(
                                                  "$panel (${_savedServices!.where((item) => item.typeId == index).length})",
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
                                            child: _savedServices!
                                                    .where((item) =>
                                                        item.typeId == index)
                                                    .isEmpty
                                                ? Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 50.0,
                                                          vertical: 28),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Không có mục $panel nào được lưu",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              displayFullScreenModal(
                                                                  context,
                                                                  AddSavedServicesPage(
                                                                    trip: widget
                                                                        .trip,
                                                                    searchType:
                                                                        index,
                                                                  ));
                                                            },
                                                            child: const Text(
                                                                'Thêm dịch vụ đầu tiên'),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : ListView.separated(
                                                    shrinkWrap: true,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: _savedServices!
                                                        .where((item) =>
                                                            item.typeId ==
                                                            index)
                                                        .length,
                                                    separatorBuilder:
                                                        (context, _) =>
                                                            const SizedBox(
                                                                height: 20),
                                                    itemBuilder: (context, i) {
                                                      final service = _savedServices!
                                                              .where((item) =>
                                                                  item.typeId ==
                                                                  index)
                                                              .toList()[
                                                          i]; // Convert iterable to list once
                                                      return SavedServiceBigCard(
                                                          service: service);
                                                    },
                                                  ),
                                          ),

                                          isExpanded: _expanded[
                                              index], // Use the correct index
                                        );
                                      }),
                                    ])
                              ],
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 80.0),
                                child: CircularProgressIndicator(),
                              ),
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
                                  Icons.favorite_border,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  'Bắt đầu lưu địa điểm tham quan, lưu trú và ăn uống trong chuyến đi tiếp theo',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 20)),
                                    child: const Text(
                                      'Thêm dịch vụ đầu tiên',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ))
                              ],
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
