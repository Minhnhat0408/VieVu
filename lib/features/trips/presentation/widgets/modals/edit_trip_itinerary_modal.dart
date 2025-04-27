import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';

class EditTripItineraryModal extends StatefulWidget {
  final List<DateTime> panels;
  final List<TripItinerary> tripItinerary;

  const EditTripItineraryModal({
    super.key,
    required this.panels,
    required this.tripItinerary,
  });

  @override
  State<EditTripItineraryModal> createState() => _EditTripItineraryModalState();
}

class _EditTripItineraryModalState extends State<EditTripItineraryModal> {
  List<DateTime> _panels = [];
  List<TripItinerary> _tripItinerary = [];
  List<bool> _expanded = [];
  final List<TripItinerary> _deleteTripItinerary = [];
  final List<TripItinerary> _updateTripItinerary = [];

  @override
  void initState() {
    super.initState();
    _panels = List.from(widget.panels);
    _tripItinerary = widget.tripItinerary.map((e) => e.copyWith()).toList();
    _expanded = List.generate(_panels.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa lịch trình'),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _expanded[index] = isExpanded;
                        });
                      },
                      expandedHeaderPadding: const EdgeInsets.all(0),
                      animationDuration: const Duration(milliseconds: 1000),
                      children: [
                        ..._panels.asMap().entries.map((item) {
                          final index = item.key;
                          final day = item.value;
                          return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                leading: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        // _panels.removeAt(index);
                                        _expanded.removeAt(index);
                                        // _deletePanels.add(day);
                                        _deleteTripItinerary.addAll(
                                            _tripItinerary.where((element) =>
                                                element.time.day == day.day &&
                                                element.time.month ==
                                                    day.month &&
                                                element.time.year == day.year));
                                        _tripItinerary.removeWhere((element) =>
                                            element.time.day == day.day &&
                                            element.time.month == day.month &&
                                            element.time.year == day.year);
                                        if (index != 0 &&
                                            _panels.length - 1 != index) {
                                          for (var item in _tripItinerary) {
                                            if (item.time.day > day.day &&
                                                item.time.month >= day.month &&
                                                item.time.year >= day.year) {
                                              item.time = item.time.subtract(
                                                  const Duration(days: 1));
                                              final tripIndex =
                                                  _updateTripItinerary
                                                      .indexWhere((element) =>
                                                          element.id ==
                                                          item.id);
                                              if (tripIndex != -1) {
                                                _updateTripItinerary[
                                                    tripIndex] = item;
                                              } else {
                                                _updateTripItinerary.add(item);
                                              }
                                            }
                                          }
                                          _panels.removeLast();
                                        } else {
                                          _panels.removeAt(index);
                                        }
                                        // make the time of all trip itinerary after this day to the previous day
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.remove_circle_outline_sharp,
                                        color: Colors.redAccent)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                title: Text(
                                    DateFormat('dd/MM/yyyy').format(day),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              );
                            },

                            canTapOnHeader: true,

                            body: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                children: [
                                  ..._tripItinerary.where((element) {
                                    // Convert element.time to local before comparing components
                                    final localElementTime =
                                        element.time.toLocal();
                                    return localElementTime.day == day.day &&
                                        localElementTime.month == day.month &&
                                        localElementTime.year == day.year;
                                  }).map((e) {
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          if (e.service?.cover != null)
                                            Row(
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl:
                                                      e.service?.cover ?? '',
                                                  width: 50,
                                                  height: 50,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                const SizedBox(width: 16),
                                              ],
                                            ),
                                          Flexible(
                                            child: Text(
                                              e.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      leading: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _deleteTripItinerary.add(e);
                                              _tripItinerary.remove(e);
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_outline_sharp,
                                              color: Colors.redAccent)),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            isExpanded:
                                _expanded[index], // Use the correct index
                          );
                        }),
                      ]),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed:
                        widget.tripItinerary.length != _tripItinerary.length
                            ? () {
                                setState(() {
                                  _panels = List.from(widget.panels);
                                  _tripItinerary = widget.tripItinerary
                                      .map((e) => e.copyWith())
                                      .toList();
                                  _expanded = List.generate(
                                      _panels.length, (index) => true);

                                  _deleteTripItinerary.clear();
                                  _updateTripItinerary.clear();
                                });
                              }
                            : null,
                    child: const Text(
                      'Hủy thay đổi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                BlocConsumer<TripItineraryBloc, TripItineraryState>(
                  listener: (context, state) {
                    if (state is TripItineraryFailure) {
                      showSnackbar(context, state.message, SnackBarState.error);
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        final realUpdateTripItinerary = _updateTripItinerary
                            .where((element) =>
                                _deleteTripItinerary
                                    .indexWhere((e) => e.id == element.id) ==
                                -1)
                            .toList();

                        if (_panels.length != widget.panels.length) {
                          context.read<TripBloc>().add(UpdateTrip(
                                tripId: widget.tripItinerary.first.tripId,
                                startDate: _panels.first,
                                endDate: _panels.last,
                              ));
                        }

                        for (var item in realUpdateTripItinerary) {
                          context
                              .read<TripItineraryBloc>()
                              .add(UpdateTripItinerary(
                                id: item.id,
                                time: item.time,
                              ));
                        }

                        for (var item in _deleteTripItinerary) {
                          context
                              .read<TripItineraryBloc>()
                              .add(DeleteTripItinerary(itineraryId: item.id));
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: state is! TripItineraryLoading
                          ? const Text('Áp dụng',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))
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
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
