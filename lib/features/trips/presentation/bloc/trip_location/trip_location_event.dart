part of 'trip_location_bloc.dart';

@immutable
sealed class TripLocationEvent {}

class InsertTripLocation extends TripLocationEvent {
  final String tripId;
  final int locationId;

  InsertTripLocation({
    required this.tripId,
    required this.locationId,
  });
}

class UpdateTripLocation extends TripLocationEvent {
  final int id;
  final bool isStartingPoint;

  UpdateTripLocation({
    required this.id,
    required this.isStartingPoint,
  });
}

class DeleteTripLocation extends TripLocationEvent {
  final String tripId;
  final int locationId;
  final String locationName;

  DeleteTripLocation({
    required this.tripId,
    required this.locationName,
    required this.locationId,
  });
}

class GetTripLocations extends TripLocationEvent {
  final String tripId;

  GetTripLocations({
    required this.tripId,
  });
}
