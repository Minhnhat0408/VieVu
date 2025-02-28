part of 'location_info_cubit.dart';

@immutable
sealed class LocationInfoState {}

final class LocationInfoInitial extends LocationInfoState {}

final class LocationInfoLoading extends LocationInfoState {}

final class LocationInfoLoaded extends LocationInfoState {
  final GenericLocationInfo locationInfo;

  LocationInfoLoaded({
    required this.locationInfo,
  });
}

final class LatLngLoaded extends LocationInfoState {
  final LatLng latLng;

  LatLngLoaded({
    required this.latLng,
  });
}
final class LocationInfoFailure extends LocationInfoState {
  final String message;

  LocationInfoFailure({
    required this.message,
  });
}

final class LocationInfoGeoLoaded extends LocationInfoState {
  final double latitude;
  final double longitude;
  final int? linkId;
  final int locationId;
  final String locationName;

  LocationInfoGeoLoaded({
    required this.latitude,
     this.linkId,
    required this.locationId,
    required this.longitude,
    required this.locationName,
  });
}

final class LocationInfoAddressLoaded extends LocationInfoState {
  final String address;
  final int locationId;
  final String cityName;

  LocationInfoAddressLoaded({
    required this.address,
    required this.locationId,
    required this.cityName,
  });
}
