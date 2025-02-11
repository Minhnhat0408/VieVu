import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/saved_service_big_card.dart';

class TripSavedServicesPage extends StatefulWidget {
  final Trip trip;
  const TripSavedServicesPage({super.key, required this.trip});

  @override
  State<TripSavedServicesPage> createState() => _TripSavedServicesPageState();
}

class _TripSavedServicesPageState extends State<TripSavedServicesPage> {
  final List<String> _panels = [
    "Điểm đến du lịch",
    "Đồ ăn & đồ uống",
    "Địa điểm tham quan",
    "Cửa hàng lưu niệm",
    "Địa điểm lưu trú",
    "Sự kiện & giải trí",
  ];

  final List<bool> _expanded = List.generate(6, (index) => false);
  List<SavedService>? _savedServices;
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
            title: Text("${widget.trip.serviceCount} mục đã lưu",
                style: const TextStyle(fontSize: 16)),
            actions: [
              ElevatedButton(onPressed: () {}, child: const Text('Thêm')),
              const SizedBox(width: 10),
              OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_alt, size: 16),
                      SizedBox(width: 5),
                      Text('Lọc'),
                    ],
                  )),
              const SizedBox(width: 20),
            ],
            pinned: true,
            automaticallyImplyLeading: false,
          ),
          BlocConsumer<SavedServiceBloc, SavedServiceState>(
            listener: (context, state) {
              // TODO: implement listener
              if (state is SavedServicesLoadedSuccess) {
                for (int i = 0; i < 6; i++) {
                  if (state.savedServices.any((item) => item.typeId == i)) {
                    setState(() {
                      _expanded[i] = true;
                    });
                  }
                }

                setState(() {
                  _savedServices = state.savedServices;
                });
              }

              if (state is SavedServiceActionSucess) {
                if (state.tripId == widget.trip.id) {
                  setState(() {
                    _savedServices!.add(state.savedService);
                  });
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
                                        int index = entry.key;
                                        String panel = entry
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
                                                ? const Center(
                                                    child: Text(
                                                      "Không có dịch vụ nào",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontStyle:
                                                              FontStyle.italic),
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
                              child: CircularProgressIndicator(),
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
