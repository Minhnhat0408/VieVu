part of 'trip_location_bloc.dart';

@immutable
sealed class TripLocationState {}

final class TripLocationInitial extends TripLocationState {}

final class TripLocationLoading extends TripLocationState {}

final class TripLocationAddedSuccess extends TripLocationState {
  final String tripId;
  final TripLocation tripLocation;

  TripLocationAddedSuccess({
    required this.tripId,
    required this.tripLocation,
  });
}

final class TripLocationDeletedSuccess extends TripLocationState {
  final String tripId;
  final int locationId;
  final String locationName;

  TripLocationDeletedSuccess({
    required this.tripId,
    required this.locationId,
    required this.locationName,
  });
}

final class TripLocationFailure extends TripLocationState {
  final String message;

  TripLocationFailure({
    required this.message,
  });
}

final class TripLocationsLoaded extends TripLocationState {
  final List<TripLocation> tripLocations;

  TripLocationsLoaded({
    required this.tripLocations,
  });
}
