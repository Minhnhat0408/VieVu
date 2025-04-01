import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/utils/conversions.dart';
import 'package:vievu/features/trips/domain/entities/saved_services.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vievu/features/trips/presentation/widgets/saved_service/saved_service_med_card.dart';

class SelectSavedServiceToItineraryModal extends StatefulWidget {
  final DateTime time;
  final String tripId;
  const SelectSavedServiceToItineraryModal({
    super.key,
    required this.time,
    required this.tripId,
  });

  @override
  State<SelectSavedServiceToItineraryModal> createState() =>
      _SelectSavedServiceToItineraryModalState();
}

class _SelectSavedServiceToItineraryModalState
    extends State<SelectSavedServiceToItineraryModal>
    with SingleTickerProviderStateMixin {
  List<SavedService>? _allSavedServices;

  final List<SavedService> _seletedServices = [];
  late TabController _tabController;
  final List<int> _notEmptyTypeIds = [];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<int> getNotEmptyTypeIds(List<SavedService> services) {
    return [-1, ...services.map((service) => service.typeId).toSet()];
  }

  @override
  Widget build(BuildContext context) {
    log(_seletedServices.toString());
    return Scaffold(
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        toolbarHeight: 70,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text("Thêm vào hành trình"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SavedServiceBloc, SavedServiceState>(
            listener: (context, state) {
              if (state is SavedServicesLoadedSuccess) {
                setState(() {
                  _allSavedServices = state.savedServices;
                });
                final tmp = getNotEmptyTypeIds(_allSavedServices!);

                _notEmptyTypeIds.addAll(tmp);
                _tabController = TabController(length: tmp.length, vsync: this);
              }
            },
          ),
        ],
        child: _allSavedServices != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    leading: null,
                    leadingWidth: 0,
                    titleSpacing: 0,
                    automaticallyImplyLeading: false,
                    title: SizedBox(
                      height: 50,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true, // Enables horizontal scrolling
                        tabAlignment: TabAlignment.start,
                        tabs: _notEmptyTypeIds.map((typeId) {
                          return Tab(
                            text: convertTypeIdToString(typeId),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ..._notEmptyTypeIds.map(
                          (typeId) {
                            return _buildSavedServices(typeId);
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<TripItineraryBloc, TripItineraryState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () {
                              // widget.onTravelTypeChanged(_travelType);
                              for (var service in _seletedServices) {
                                context
                                    .read<TripItineraryBloc>()
                                    .add(InsertTripItinerary(
                                      latitude: service.latitude,
                                      longitude: service.longitude,
                                      title: service.name,
                                      time: widget.time,
                                      tripId: widget.tripId,
                                      serviceId: service.dbId,
                                    ));
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: state is! TripItineraryLoading
                                ? const Text('Áp dụng',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Đang cập nhật',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSavedServices(int typeId) {
    final serviceOfTypes = _allSavedServices!
        .where((s) => typeId == -1 || s.typeId == typeId)
        .toList();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        // use ListView.builder to have separated items
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _seletedServices.isEmpty
                      ? "Chọn mục cần thêm"
                      : "Đã chọn ${_seletedServices.length} mục",
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (_seletedServices.length != serviceOfTypes.length) {
                        _seletedServices.clear();
                        _seletedServices.addAll(serviceOfTypes);
                      } else {
                        _seletedServices.clear();
                      }
                    });
                  },
                  child: Text(
                      _seletedServices.length != serviceOfTypes.length
                          ? "Chọn tất cả"
                          : "Hủy",
                      style: const TextStyle(
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: serviceOfTypes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 20), // Space between items
              itemBuilder: (context, index) {
                final service = serviceOfTypes[index];
                return InkWell(
                    onTap: () {
                      setState(() {
                        if (_seletedServices.contains(service)) {
                          _seletedServices.remove(service);
                        } else {
                          _seletedServices.add(service);
                        }
                      });
                    },
                    child: SavedServiceMedCard(
                        service: service,
                        isSelected: _seletedServices.contains(service)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
