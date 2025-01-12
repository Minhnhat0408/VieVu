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

final class LocationInfoFailure extends LocationInfoState {
  final String message;

  LocationInfoFailure({
    required this.message,
  });
}

final class LocationInfoAddressLoaded extends LocationInfoState {
  final String address;

  LocationInfoAddressLoaded({
    required this.address,
  });
}
