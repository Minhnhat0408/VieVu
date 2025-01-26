import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';

class SavedServiceToTripModal extends StatefulWidget {
  final Function(List<Trip> trips, List<Trip> trips2) onTripsChanged;
  const SavedServiceToTripModal({
    super.key,
    required this.onTripsChanged,
  });

  @override
  State<SavedServiceToTripModal> createState() => _SavedServiceToTripModalState();
}

class _SavedServiceToTripModalState extends State<SavedServiceToTripModal> {
  final List<Trip> _selectedTrips = [];
  final List<Trip> _unselectedTrips = [];
  List<Trip> _currentSelectedTrips = [];
  List<Trip> _initialSelectedTrips = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is SavedToTripLoadedSuccess) {
          _currentSelectedTrips =
              state.trips.where((trip) => trip.isSaved).toList();
          _initialSelectedTrips =
              state.trips.where((trip) => trip.isSaved).toList();
        }
      },
      builder: (context, state) {
        if (state is TripLoading) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is SavedToTripLoadedSuccess) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    const Text(
                      "Chọn chuyến đi muốn lưu",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...state.trips.map(
                        (trip) {
                          return CheckboxListTile(
                            value: _currentSelectedTrips.contains(trip),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 20),
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8), // Set the border radius
                                  child: CachedNetworkImage(
                                    imageUrl: trip.cover ?? '',
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            'assets/images/trip_placeholder.png'),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        12), // Add some space between the image and the text
                                Expanded(
                                  // Ensure the text takes the available space
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Align text to the start
                                    children: [
                                      Text(
                                        trip.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "${trip.locations.length} điểm đến",
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _currentSelectedTrips.add(trip);

                                  if (!_initialSelectedTrips.contains(trip)) {
                                    log('hello');
                                    _selectedTrips.add(trip);
                                    _unselectedTrips.remove(trip);
                                  }
                                } else {
                                  _currentSelectedTrips.remove(trip);
                                  if (_initialSelectedTrips.contains(trip)) {
                                    log("hi");
                                    _unselectedTrips.add(trip);
                                    _selectedTrips.remove(trip);
                                  }
                                }

                                log(_selectedTrips.toString());

                                log(_unselectedTrips.toString());
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          if (_currentSelectedTrips.isNotEmpty) {
                            _currentSelectedTrips = [];
                          }
                          _currentSelectedTrips = [];
                        });
                      },
                      child: Text(
                          _currentSelectedTrips.isNotEmpty ? "Hủy" : "Tất cả",
                          style: const TextStyle(
                              decoration: TextDecoration.underline))),
                  ElevatedButton(
                    onPressed: () {
                      widget.onTripsChanged(_selectedTrips, _unselectedTrips);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text("Áp dụng"),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
