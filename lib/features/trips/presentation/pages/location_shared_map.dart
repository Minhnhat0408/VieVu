import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/auth/domain/entities/user.dart' as auth;
import 'package:vievu/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vievu/features/trips/presentation/pages/trip_itinerary_detail_page.dart';
import 'package:vievu/init_dependencies.dart';

class LocationSharedMap extends StatefulWidget {
  final List<TripItinerary> tripItineraries;
  final String tripId;
  const LocationSharedMap(
      {super.key, required this.tripItineraries, required this.tripId});

  @override
  State<LocationSharedMap> createState() => _LocationSharedMapState();
}

class MarkerPoint {
  final LatLng point;
  final String id;
  final String type;
  MarkerPoint(this.point, this.id, {this.type = 'itinerary'});
}

class _LocationSharedMapState extends State<LocationSharedMap>
    with TickerProviderStateMixin {
  LocationPermission locationPermission = LocationPermission.denied;
  late auth.User currentUser;

  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  SupabaseClient client = serviceLocator<SupabaseClient>();
  int activeIndex = 0;
  MarkerPoint? _selectedMarker1;
  MarkerPoint? _selectedMarker2;
  List<auth.User> sharedPosUsers = [];
  List<auth.User> usersActive = [];
  late RealtimeChannel _positionChannel;
  bool _showItinerary = false;
  double? _distanceBetweenMarkers;
  // List<
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(
          vsync: this,
          // mapController: _mapController,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          cancelPreviousAnimations: true);
  void _animateMapTo(LatLng destination) {
    _animatedMapController.animateTo(
      dest: destination,
      rotation: 0.0,
    );
  }

  void _handleMarkerLongPress(MarkerPoint pos) {
    setState(() {
      if (_selectedMarker1 == null) {
        _selectedMarker1 = pos;
      } else if (_selectedMarker2 == null && _selectedMarker1?.id != pos.id) {
        _selectedMarker2 = pos;
        // Calculate distance between the two markers
        _distanceBetweenMarkers = Geolocator.distanceBetween(
            _selectedMarker1!.point.latitude,
            _selectedMarker1!.point.longitude,
            _selectedMarker2!.point.latitude,
            _selectedMarker2!.point.longitude);
      } else {
        // Reset selections if both are already selected or same marker is selected again
        _selectedMarker1 = pos;
        _selectedMarker2 = null;
        _distanceBetweenMarkers = null;
      }
    });
  }

  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();

    currentUser = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    _positionChannel = client
        .channel("realtime:trip_${widget.tripId}_location")
        .onPresenceLeave((payload) {
      log('someone left');
      log(payload.leftPresences.toString());
      log('left id : ${payload.leftPresences.first.payload['data']['id']}');
      log('current id : ${currentUser.id}');
      final id = payload.leftPresences.first.payload['data']['id'];
      if (id == currentUser.id) {
        Navigator.of(context).pop();
      }
    }).onPresenceSync((payload) {
      usersActive = _positionChannel.presenceState().map((e) {
        final user = e.presences.first.payload['data'];

        return auth.User.fromJson(user);
      }).toList();

      // add item that not in sharedPosUsers
      for (var user in usersActive) {
        final index =
            sharedPosUsers.indexWhere((element) => element.id == user.id);
        if (index == -1) {
          setState(() {
            sharedPosUsers.add(user);
          });
        } else {
          setState(() {
            sharedPosUsers[index] = user;
          });
        }
      }
    }).subscribe();

    _updateAndStoreCurrentLocation();
  }

  Future<void> _updateAndStoreCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      // log('Current Position: ${position.latitude}, ${position.longitude}');

      setState(() {
        currentUser.latitude = position.latitude;
        currentUser.longitude = position.longitude;
      });

      service.invoke('listenToLocation', {
        'channel_name': "realtime:trip_${widget.tripId}_location",
        "data": currentUser.toJson()
      });

      final locationBox = Hive.box('locationBox');
      locationBox.put('latitude', position.latitude);
      locationBox.put('longitude', position.longitude);
    } catch (e) {
      showSnackbar(context, 'Không thể xác định vị trí của bạn.', 'error');
    }
  }

  @override
  void dispose() {
    log("dispose");
    super.dispose();
    _animatedMapController.dispose();

    _positionChannel.unsubscribe();
    // service.invoke('stop');
  }

  void _resetSelections() {
    setState(() {
      _selectedMarker1 = null;
      _selectedMarker2 = null;
      _distanceBetweenMarkers = null;
    });
  }

  Color _getMarkerBorderColor(MarkerPoint member, BuildContext context) {
    if (_selectedMarker1?.id == member.id ||
        _selectedMarker2?.id == member.id) {
      return Theme.of(context).colorScheme.error;
    }
    // check if member id in userActive
    if (member.type == 'user') {
      if (usersActive.indexWhere((element) => element.id == member.id) != -1) {
        return Theme.of(context).colorScheme.primary;
      }
      return Colors.grey;
    }

    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chia sẻ vị trí"),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            service.invoke("stopListen");
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          // ...usersActive.take(6).map(
          //       (e) => GestureDetector(
          //         onTap: () {
          //           _animateMapTo(LatLng(e.latitude!, e.longitude!));
          //         },
          //         child: Align(
          //           widthFactor: 0.6,
          //           child: Container(
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               border: Border.all(
          //                 color: _getMarkerBorderColor(
          //                     MarkerPoint(
          //                         LatLng(e.latitude!, e.longitude!), e.id),
          //                     context),
          //                 width: 2.0,
          //               ),
          //             ),
          //             child: CachedNetworkImage(
          //               imageUrl: e.avatarUrl ?? "",
          //               errorWidget: (context, url, error) => Image.asset(
          //                 'assets/images/trip_placeholder.avif', // Fallback if loading fails
          //                 fit: BoxFit.cover,
          //               ),
          //               imageBuilder: (context, imageProvider) => CircleAvatar(
          //                 backgroundImage: imageProvider,
          //                 radius: 16,
          //               ),
          //               // width: 70,
          //               // height: 70,
          //               fit: BoxFit.cover,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          // const SizedBox(
          //   width: 20,
          // )
        ],
      ),
      body: currentUser.latitude != null && currentUser.longitude != null
          ? Stack(
              children: [
                FlutterMap(
                  mapController: _animatedMapController.mapController,
                  options: MapOptions(
                      initialZoom: 3,
                      interactionOptions: const InteractionOptions(
                        enableMultiFingerGestureRace: true,
                      ),
                      onTap: (_, __) => _resetSelections(),
                      initialCenter:
                          LatLng(currentUser.latitude!, currentUser.longitude!),
                      minZoom: 3),
                  children: [
                    TileLayer(
                      // Display map tiles from any source
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName: 'com.example.vn_travel_companion',
                      // And many more recommended properties!
                    ),
                    if (_selectedMarker1 != null && _selectedMarker2 != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            strokeWidth: 4,
                            points: [
                              LatLng(_selectedMarker1!.point.latitude,
                                  _selectedMarker1!.point.longitude),
                              LatLng(_selectedMarker2!.point.latitude,
                                  _selectedMarker2!.point.longitude),
                            ],
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    MarkerLayer(markers: [
                      Marker(
                        width: 60,
                        height: 60,

                        point: LatLng(
                            currentUser.latitude!, currentUser.longitude!),
                        //circle avatar with border
                        child: GestureDetector(
                          onLongPress: () => _handleMarkerLongPress(MarkerPoint(
                              LatLng(currentUser.latitude!,
                                  currentUser.longitude!),
                              currentUser.id,
                              type: 'user')),
                          onTap: () {
                            setState(() {
                              // buttonCarouselController.animateToPage(item.key,
                              //     duration: const Duration(milliseconds: 300),
                              //     curve: Curves.easeInOut);
                              // activeIndex = tripItinerary.id;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getMarkerBorderColor(
                                    MarkerPoint(
                                        LatLng(currentUser.latitude!,
                                            currentUser.longitude!),
                                        currentUser.id,
                                        type: 'user'),
                                    context),
                                width: 4.0,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: currentUser.avatarUrl ?? "",
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                fit: BoxFit.cover,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                backgroundImage: imageProvider,
                                radius: 30,
                              ),
                              // width: 70,
                              // height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      ...sharedPosUsers
                          .where((user) => user.latitude != null)
                          .map((member) {
                        return Marker(
                          width: 70,
                          height: 70,
                          point: LatLng(member.latitude!, member.longitude!),
                          //circle avatar with border
                          child: GestureDetector(
                            onLongPress: () => _handleMarkerLongPress(
                                MarkerPoint(
                                    LatLng(member.latitude!, member.longitude!),
                                    member.id,
                                    type: 'user')),
                            onTap: () {
                              setState(() {
                                // buttonCarouselController.animateToPage(item.key,
                                //     duration: const Duration(milliseconds: 300),
                                //     curve: Curves.easeInOut);
                                // activeIndex = tripItinerary.id;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getMarkerBorderColor(
                                      MarkerPoint(
                                          LatLng(member.latitude!,
                                              member.longitude!),
                                          member.id,
                                          type: 'user'),
                                      context),
                                  width: 4.0,
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: member.avatarUrl ?? "",
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                  fit: BoxFit.cover,
                                ),
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                  backgroundImage: imageProvider,
                                  radius: 30,
                                ),
                                // width: 70,
                                // height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }),
                      if (_showItinerary)
                        ...widget.tripItineraries.asMap().entries.map((item) {
                          final tripItinerary = item.value;
                          final index = item.key;

                          return Marker(
                            width: activeIndex == tripItinerary.id ? 60 : 50,
                            height: activeIndex == tripItinerary.id ? 60 : 50,
                            point: LatLng(tripItinerary.latitude,
                                tripItinerary.longitude),
                            child: GestureDetector(
                              onLongPress: () => _handleMarkerLongPress(
                                  MarkerPoint(
                                      LatLng(tripItinerary.latitude,
                                          tripItinerary.longitude),
                                      tripItinerary.id.toString())),
                              onTap: () {
                                setState(() {
                                  buttonCarouselController.animateToPage(
                                      item.key,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                  activeIndex = tripItinerary.id;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getMarkerBorderColor(
                                        MarkerPoint(
                                            LatLng(tripItinerary.latitude,
                                                tripItinerary.longitude),
                                            tripItinerary.id.toString()),
                                        context),
                                    width: 4.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: activeIndex ==
                                          tripItinerary.id
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white, // ,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: activeIndex == tripItinerary.id
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                if (_distanceBetweenMarkers != null)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${(_distanceBetweenMarkers! / 1000).toStringAsFixed(2)} km',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                    child: CircularMenu(
                        toggleButtonColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        alignment: const Alignment(0.95, 0.95),
                        toggleButtonIconColor:
                            Theme.of(context).colorScheme.primary,
                        startingAngleInRadian:
                            3.14, // Example: 180 degrees (π radians)
                        endingAngleInRadian:
                            3.14 * 3 / 2, // Example: 360 degrees (2π radians)
                        items: [
                      CircularMenuItem(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        icon: Icons.rotate_right,
                        iconColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          // Rotate the map by 45 degrees
                          _animatedMapController.animatedRotateTo(0);
                        },
                      ),
                      CircularMenuItem(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        icon: _showItinerary
                            ? Icons.group_outlined
                            : Icons.card_travel,
                        onTap: () {
                          setState(() {
                            _showItinerary = !_showItinerary;
                          });
                        },
                        iconColor: Theme.of(context).colorScheme.primary,
                      ),
                      CircularMenuItem(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          icon: Icons.person,
                          iconColor: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            _animateMapTo(LatLng(
                                currentUser.latitude!, currentUser.longitude!));
                          }),
                    ])),
                if (!_showItinerary)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 10),
                    child: Row(
                      children: [
                        ...usersActive.map(
                          (e) => GestureDetector(
                            onTap: () {
                              _animateMapTo(LatLng(e.latitude!, e.longitude!));
                            },
                            child: Align(
                              widthFactor: 0.8,
                              alignment: Alignment.topLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getMarkerBorderColor(
                                        MarkerPoint(
                                            LatLng(e.latitude!, e.longitude!),
                                            e.id),
                                        context),
                                    width: 2.0,
                                  ),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: e.avatarUrl ?? "",
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                    fit: BoxFit.cover,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 20,
                                  ),
                                  // width: 70,
                                  // height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showItinerary)
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
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 10, 0, 10),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                                        widget.tripItineraries[index].note ??
                                            '',
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

                          _animateMapTo(LatLng(
                              widget.tripItineraries[index].latitude,
                              widget.tripItineraries[index].longitude));
                        }),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
