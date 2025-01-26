import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_attractions/nearby_attractions_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/attraction_small_card.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class NearbyAttractionSection extends StatefulWidget {
  const NearbyAttractionSection({super.key});

  @override
  State<NearbyAttractionSection> createState() =>
      _NearbyAttractionSectionState();
}

class _NearbyAttractionSectionState extends State<NearbyAttractionSection> {
  LocationPermission locationPermission = LocationPermission.denied;
  List<double>? userPos;
  final nearbyAttractionsCubit = serviceLocator<NearbyAttractionsCubit>();

  @override
  void initState() {
    super.initState();
    _initializeHiveAndCheckLocation();
  }

  Future<void> _initializeHiveAndCheckLocation() async {
    await Hive.initFlutter();
    await Hive.openBox('locationBox');
    await _checkLocationPermissionAndHandle();

    if (_hasLocationPermission() && userPos != null) {
      _fetchNearbyAttractions();
    }
  }

  Future<void> _checkLocationPermissionAndHandle() async {
    final status = await Geolocator.checkPermission();
    setState(() {
      locationPermission = status;
    });

    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        await _updateAndStoreCurrentLocation();
      } else {
        // Load the stored position
        _loadStoredPosition();
      }
    } else {
      // No permission: Prompt user to enable location services
      _loadStoredPosition();
    }
  }

  Future<void> _updateAndStoreCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      log('Current Position: ${position.latitude}, ${position.longitude}');

      setState(() {
        userPos = [position.latitude, position.longitude];
      });

      // Save position to Hive
      final locationBox = Hive.box('locationBox');
      locationBox.put('latitude', position.latitude);
      locationBox.put('longitude', position.longitude);
    } catch (e) {
      showSnackbar(context, 'Không thể xác định vị trí của bạn.', 'error');
    }
  }

  void _loadStoredPosition() {
    final locationBox = Hive.box('locationBox');
    final latitude = locationBox.get('latitude') as double?;
    final longitude = locationBox.get('longitude') as double?;

    if (latitude != null && longitude != null) {
      setState(() {
        userPos = [latitude, longitude];
      });
      log('Loaded Stored Position: $userPos');
    } else {
      log('No stored position found.');
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log('Location permission denied.');
      return;
    }

    setState(() {
      locationPermission = permission;
    });

    await _updateAndStoreCurrentLocation();

    if (userPos != null) {
      _fetchNearbyAttractions();
    }
  }

  void _fetchNearbyAttractions() {
    if (userPos != null) {
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      nearbyAttractionsCubit.fetchNearbyAttractions(
        latitude: userPos![0],
        userId: userId,
        longitude: userPos![1],
        limit: 5,
        offset: 0,
        radius: 30,
      );
    } else {
      log('User position is null. Skipping fetching attractions.');
    }
  }

  bool _hasLocationPermission() {
    return locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always;
  }

  @override
  Widget build(BuildContext context) {
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Text(
              'Xem địa điểm thú vị lân cận.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _getCurrentLocation(),
              child: Text(
                'Bật dịch vụ Định vị',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Điểm du lịch lân cận',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        BlocConsumer<NearbyAttractionsCubit, NearbyAttractionsState>(
            listener: (context, state) {
          if (state is NearbyAttractionsFailure) {
            showSnackbar(context, state.message, 'error');
          }
        }, builder: (context, state) {
          if (state is NearbyAttractionsLoadedSuccess) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                      state.attractions.length,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: AttractionSmallCard(
                              attraction: state.attractions[index],
                            ),
                          )),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        }),
      ],
    );
  }
}
