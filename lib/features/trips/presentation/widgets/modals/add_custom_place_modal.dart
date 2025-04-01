import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';

class AddCustomPlaceModal extends StatefulWidget {
  final String tripId;
  final DateTime date;
  const AddCustomPlaceModal(
      {super.key, required this.tripId, required this.date});

  @override
  State<AddCustomPlaceModal> createState() => _AddCustomPlaceModalState();
}

class _AddCustomPlaceModalState extends State<AddCustomPlaceModal>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  final TextEditingController textController = TextEditingController();
  Marker? _selectedMarker; // Store the single marker
  bool openPanel = false;
  double longitude = 0.0;
  double latitude = 0.0;
  final PanelController panelController = PanelController();
  @override
  void initState() {
    super.initState();

    _animatedMapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventTap) {
        log('Map tapped at: ${event.tapPosition}');

        LatLng tappedLocation = event.tapPosition; // Get LatLng of tap
        setState(() {
          latitude = tappedLocation.latitude;
          longitude = tappedLocation.longitude;
          panelController.open();
        });
        _addMarker(tappedLocation, 12);
        context.read<LocationInfoCubit>().convertGeoLocationToAddress(
            tappedLocation.latitude, tappedLocation.longitude);
      }
      if (event is MapEventDoubleTapZoom) {
        panelController.close();
      }
    });
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position, double? zoom) {
    setState(() {
      _selectedMarker = Marker(
        point: position,
        width: 40,
        height: 40,
        rotate: true,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      );
    });
    _animatedMapController.animateTo(
      dest: position,
      // zoom: zoom ?? 12,
      rotation: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: "Thêm địa điểm",
      body: SlidingUpPanel(
        controller: panelController,
        defaultPanelState: PanelState.CLOSED,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        maxHeight: MediaQuery.of(context).size.height * 0.35,
        minHeight: 40,
        color: Theme.of(context).colorScheme.surface,
        panelBuilder: (scrollController) {
          return BlocConsumer<LocationInfoCubit, LocationInfoState>(
            listener: (context, state) {
              if (state is LocationInfoAddressLoaded) {
                textController.text = state.address;
                panelController.open();
              }
              if (state is LatLngLoaded) {
                latitude = state.latLng.latitude;
                longitude = state.latLng.longitude;
                panelController.open();
                _addMarker(LatLng(latitude, longitude), 15);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Chọn vị trí trên bản đồ hoặc nhập địa chỉ ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: textController,
                          enabled: state is LocationInfoLoading ? false : true,
                          decoration: InputDecoration(
                            hintText: "Nhập địa chỉ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: state is LocationInfoLoading
                                ? Container(
                                    width: 30,
                                    alignment: Alignment.center,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : null,
                          ),
                          onSubmitted: (value) {
                            context
                                .read<LocationInfoCubit>()
                                .convertAddressToLatLng(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tọa độ: ${latitude.toStringAsPrecision(10)}, ${longitude.toStringAsPrecision(10)}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (state is LocationInfoAddressLoaded) {
                              context.read<TripItineraryBloc>().add(
                                  InsertTripItinerary(
                                      latitude: latitude,
                                      longitude: longitude,
                                      title: state.address,
                                      time: widget.date,
                                      tripId: widget.tripId));
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Thêm địa điểm'),
                        ),
                      ],
                    ),
                  )
                ]),
              );
            },
          );
        },
        body: Stack(
          children: [
            FlutterMap(
              mapController: _animatedMapController.mapController,
              options: const MapOptions(
                interactionOptions: InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
                initialCenter: LatLng(21.030735, 105.8524),
                initialZoom: 9,
                minZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.vn_travel_companion',
                ),
                MarkerLayer(
                    markers: _selectedMarker != null ? [_selectedMarker!] : []),
              ],
            ),
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton(
                heroTag: 'rotate',
                onPressed: () {
                  _animatedMapController.animatedRotateTo(0);
                },
                child: const Icon(Icons.rotate_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
