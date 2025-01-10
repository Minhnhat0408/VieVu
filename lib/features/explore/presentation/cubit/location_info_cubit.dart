import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/location_repository.dart';

part 'location_info_state.dart';

class LocationInfoCubit extends Cubit<LocationInfoState> {
  final LocationRepository _locationRepository;
  LocationInfoCubit({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(LocationInfoInitial());

  Future<void> fetchLocationInfo(int locationId) async {
    emit(LocationInfoLoading());
    final result = await _locationRepository.getLocationGeneralInfo(
        locationId: locationId);
    result.fold(
      (failure) => emit(LocationInfoFailure(message: failure.message)),
      (location) => emit(LocationInfoLoaded(locationInfo: location)),
    );
  }

  Future<void> convertGeoLocationToAddress(
      double latitude, double longitude) async {
    emit(LocationInfoLoading());
    final result = await _locationRepository.convertGeoLocationToAddress(
        latitude: latitude, longitude: longitude);
    result.fold(
      (failure) => emit(LocationInfoFailure(message: failure.message)),
      (address) => emit(LocationInfoAddressLoaded(address: address)),
    );
  }
}
