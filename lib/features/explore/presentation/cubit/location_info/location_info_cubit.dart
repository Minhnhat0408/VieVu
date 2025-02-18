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

  Future<void> fetchLocationInfo({
    required int locationId,
    required String userId,
    required String locationName,
  }) async {
    emit(LocationInfoLoading());
    final result = await _locationRepository.getLocationGeneralInfo(
        locationId: locationId, userId: userId, locationName: locationName);
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
      (geo) => emit(LocationInfoAddressLoaded(
          address: geo.address, cityName: geo.cityName, locationId: geo.id)),
    );
  }

  Future<void> convertAddressToGeoLocation(String address, int id) async {
    emit(LocationInfoLoading());
    final result = await _locationRepository.convertAddressToGeoLocation(
      address: address,
    );
    result.fold(
      (failure) => emit(LocationInfoFailure(message: failure.message)),
      (geo) => emit(LocationInfoGeoLoaded(
          latitude: geo.latitude,
          longitude: geo.longitude,
          linkId: id,
          locationId: geo.id,
          locationName: geo.cityName)),
    );
  }
}
