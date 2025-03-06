import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_itinerary_detail_page.dart';

class MapViewModal extends StatefulWidget {
  final List<TripItinerary> tripItineraries;
  final DateTime panel;
  const MapViewModal({
    super.key,
    required this.tripItineraries,
    required this.panel,
  });

  @override
  State<MapViewModal> createState() => _MapViewModalState();
}

class _MapViewModalState extends State<MapViewModal>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      zoom: 15,
      rotation: 0.0,
    );
  }

  int activeIndex = 0;
  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lộ trình ${DateFormat('dd/MM/yyyy').format(widget.panel)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
                // initialCenter: LatLng(state.location.latitude,
                //     state.location.longitude), // Center the map over London
                initialCameraFit: CameraFit.coordinates(
                    coordinates: widget.tripItineraries
                        .map(
                          (e) => LatLng(e.latitude, e.longitude),
                        )
                        .toList()),
                initialZoom: 11,
                minZoom: 5),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                userAgentPackageName: 'com.example.vn_travel_companion',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    strokeWidth: 4,
                    points: [
                      ...widget.tripItineraries.map(
                        (e) => LatLng(e.latitude, e.longitude),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              MarkerLayer(markers: [
                ...widget.tripItineraries.asMap().entries.map((item) {
                  final tripItinerary = item.value;
                  final index = item.key;

                  return Marker(
                    width: activeIndex == tripItinerary.id ? 60 : 50,
                    height: activeIndex == tripItinerary.id ? 60 : 50,
                    point:
                        LatLng(tripItinerary.latitude, tripItinerary.longitude),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          buttonCarouselController.animateToPage(item.key,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                          activeIndex = tripItinerary.id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4.0,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: activeIndex == tripItinerary.id
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white, // ,
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: activeIndex == tripItinerary.id
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ]),
            ],
          ),
          Positioned(
            bottom: 70,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: 'rotate',
              onPressed: () {
                // Rotate the map by 45 degrees
                _animatedMapController.animatedRotateTo(0);
              },
              child: const Icon(Icons.rotate_right),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CarouselSlider.builder(
              itemCount: widget.tripItineraries.length,
              carouselController: buttonCarouselController,
              itemBuilder: (context, index, realIndex) {
                final service = widget.tripItineraries[index].service;

                return InkWell(
                  onTap: () {
                    displayFullScreenModal(
                        context,
                        TripItineraryDetailPage(
                          itineraries: widget.tripItineraries,
                          index: index,
                        ));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (service != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.network(
                                service.cover,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    index == 0 ? 'Bắt đầu:' : 'Dừng:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.tripItineraries[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.tripItineraries[index].note ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 130,
                initialPage: 0,
                enlargeCenterPage: true,
                reverse: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) => setState(() {
                  activeIndex = widget.tripItineraries[index].id;

                  _animateMapTo(LatLng(widget.tripItineraries[index].latitude,
                      widget.tripItineraries[index].longitude));
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
