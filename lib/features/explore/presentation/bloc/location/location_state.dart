part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationFailure extends LocationState {
  final String message;

  LocationFailure({
    required this.message,
  });
}

final class LocationDetailsLoadedSuccess extends LocationState {
  final Location location;

  LocationDetailsLoadedSuccess({
    required this.location,
  });
}

final class LocationError extends LocationState {
  final String message;

  LocationError({
    required this.message,
  });
}

final class LocationsLoadedSuccess extends LocationState {
  final List<Location> locations;

  LocationsLoadedSuccess({
    required this.locations,
  });
}
