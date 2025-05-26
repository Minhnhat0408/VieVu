import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart'; // Import for DeepCollectionEquality
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';

class SavedToTripModal extends StatefulWidget {
  final Function(List<Trip> newlySelected, List<Trip> newlyUnselected)
      onTripsChanged;

  const SavedToTripModal({
    super.key,
    required this.onTripsChanged,
  });

  @override
  State<SavedToTripModal> createState() => _SavedToTripModalState();
}

class _SavedToTripModalState extends State<SavedToTripModal> {
  Set<Trip> _currentSelectedTrips = {};
  Set<Trip> _initialSelectedTrips = {};
  bool _initialLoad = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
  }

  // Function to check if there are changes
  void _checkForChanges() {
    final bool changed =
        !SetEquality().equals(_currentSelectedTrips, _initialSelectedTrips);
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Building modal. Current selected: ${_currentSelectedTrips.length}, Initial: ${_initialSelectedTrips.length}, Has Changes: $_hasChanges");

    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        // Populate initial state only on the first successful load
        if (state is SavedToTripLoadedSuccess && _initialLoad) {
          final initiallySaved =
              state.trips.where((trip) => trip.isSaved).toSet();
          // Use setState to ensure the UI rebuilds after initial load
          setState(() {
            _initialSelectedTrips = initiallySaved;
            _currentSelectedTrips = Set.from(initiallySaved);
            _initialLoad = false;
            _hasChanges = false;
          });
          log("Initial state loaded. Initial: ${_initialSelectedTrips.length}");
        }
      },
      builder: (context, state) {
        Widget content;

        if (state is TripLoading && _initialLoad) {
          // Show loading only on initial load
          content = const SizedBox(
            height: 400, // Define a reasonable height for loading state
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is SavedToTripLoadedSuccess) {
          if (state.trips.isEmpty) {
            // Show message if no trips are available
            content = const SizedBox(
              height: 150, // Adjust height as needed
              child: Center(
                child: Text(
                  "Hiện chưa có chuyến đi nào.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          } else {
            // Build the list of trips
            content = Flexible(
              // Use Flexible to allow list to take available space
              child: ListView.builder(
                // Use ListView.builder for better performance
                shrinkWrap: true, // Important with Flexible in a Column
                itemCount: state.trips.length,
                itemBuilder: (context, index) {
                  final trip = state.trips[index];
                  final bool isSelected = _currentSelectedTrips.contains(trip);

                  return CheckboxListTile(
                    value: isSelected,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 20), // Adjust padding
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: trip.cover ?? '',
                            placeholder: (context, url) => Container(
                              // Simple placeholder
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child:
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                                'assets/images/trip_placeholder.avif',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${trip.serviceCount} địa điểm", // Use serviceCount, handle null
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey), // Subdued color
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onChanged: (value) {
                      // Simplified logic using Set
                      setState(() {
                        if (value == true) {
                          _currentSelectedTrips.add(trip);
                        } else {
                          _currentSelectedTrips.remove(trip);
                        }
                        _checkForChanges(); // Check if changes occurred
                      });
                    },
                  );
                },
              ),
            );
          }
        } else {
          content = const SizedBox(
              height: 150, child: Center(child: CircularProgressIndicator()));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 10, top: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    "Lưu vào chuyến đi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              height: 1,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.5, // Max 50% of screen height
              ),
              child: content,
            ),
            if (state is SavedToTripLoadedSuccess) ...[
              const Divider(thickness: 1, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: !_hasChanges
                          ? null
                          : () {
                              // Calculate differences when applying
                              final newlySelected = _currentSelectedTrips
                                  .difference(_initialSelectedTrips)
                                  .toList();
                              final newlyUnselected = _initialSelectedTrips
                                  .difference(_currentSelectedTrips)
                                  .toList();

                              log("Applying changes. Newly Selected: ${newlySelected.length}, Newly Unselected: ${newlyUnselected.length}");
                              widget.onTripsChanged(
                                  newlySelected, newlyUnselected);
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                      child: const Text("Áp dụng"),
                    ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
