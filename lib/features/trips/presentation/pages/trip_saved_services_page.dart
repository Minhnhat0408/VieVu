import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/add_saved_services_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/saved_service/saved_service_big_card.dart';

class TripSavedServicesPage extends StatefulWidget {
  final Trip trip;
  const TripSavedServicesPage({super.key, required this.trip});

  @override
  State<TripSavedServicesPage> createState() => _TripSavedServicesPageState();
}

class _TripSavedServicesPageState extends State<TripSavedServicesPage>
    with AutomaticKeepAliveClientMixin<TripSavedServicesPage> {
  final Map<String, int> _panels = {
    "Địa điểm tham quan": 2,
    "Đồ ăn & đồ uống": 1,
    "Địa điểm lưu trú": 4,
    "Sự kiện & giải trí": 5,
    "Điểm đến du lịch": 0,
  };

  @override
  bool get wantKeepAlive => true;
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
        _expanded[i] = true;
      }
    }
    setState(() {
      _savedServices = state.savedServices;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      key: const PageStorageKey('trip-saved-services-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverAppBar(
          primary: false,
          floating: true,
          title: Text(
              "${_savedServices != null ? _savedServices!.length : widget.trip.serviceCount} mục đã lưu",
              style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
                onPressed: () {
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
            if (state is SavedServiceActionSucess &&
                state.tripId == widget.trip.id) {
              setState(() {
                _savedServices!.add(state.savedService);
                _expanded[state.savedService.typeId] = true;
              });
            }
            if (state is SavedServiceDeleteSuccess &&
                state.tripId == widget.trip.id) {
              setState(() {
                _savedServices!.removeWhere((item) => item.id == state.linkId);
              });
            }
          },
          builder: (context, state) {
            if (_savedServices == null) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 70.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    String panel = _panels.keys.elementAt(index);
                    int typeId = _panels.values.elementAt(index);
                    List<SavedService> services = _savedServices!
                        .where((item) => item.typeId == typeId)
                        .toList();

                    return ExpansionPanelList(
                      expansionCallback: (i, isExpanded) {
                        setState(() {
                          _expanded[typeId] = !isExpanded;
                        });
                      },
                      expandedHeaderPadding: EdgeInsets.zero,
                      animationDuration: const Duration(milliseconds: 300),
                      children: [
                        ExpansionPanel(
                          headerBuilder: (context, isExpanded) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: Text("$panel (${services.length})",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          canTapOnHeader: true,
                          body: services.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text("Không có mục $panel nào được lưu",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic)),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            displayFullScreenModal(
                                                context,
                                                AddSavedServicesPage(
                                                  trip: widget.trip,
                                                  searchType: typeId,
                                                ));
                                          },
                                          child: const Text(
                                              'Thêm dịch vụ đầu tiên'),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: services
                                      .map((service) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: SavedServiceBigCard(
                                                service: service),
                                          ))
                                      .toList(),
                                ),
                          isExpanded: _expanded[typeId],
                        ),
                      ],
                    );
                  },
                  childCount: _panels.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
