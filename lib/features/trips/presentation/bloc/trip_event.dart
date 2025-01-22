part of 'trip_bloc.dart';

@immutable
sealed class TripEvent {}


final class AddTrip extends TripEvent {
  final String name;
  final String userId;

  AddTrip(this.name, this.userId);
}

final class UpdateTrip extends TripEvent {
  final Trip trip;

  UpdateTrip(this.trip);
}

final class DeleteTrip extends TripEvent {
  final String id;

  DeleteTrip(this.id);
}

final class GetCurrentUserTrips extends TripEvent {
  final String userId;
  final String? status;
  final bool? isPublished;
  final int limit;
  final int offset;

  GetCurrentUserTrips({
    required this.userId,
    this.status,
    this.isPublished,
    required this.limit,
    required this.offset,
  });
}
