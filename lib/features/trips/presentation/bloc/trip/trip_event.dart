part of 'trip_bloc.dart';

@immutable
sealed class TripEvent {}

final class AddTrip extends TripEvent {
  final String name;
  final String userId;

  AddTrip(this.name, this.userId);
}

final class UpdateTrip extends TripEvent {
  final String tripId;
  final File? cover;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxMember;
  final String? status;
  final bool? isPublished;
  final List<String>? transports;

  UpdateTrip({
    required this.tripId,
    this.name,
    this.description,
    this.cover,
    this.startDate,
    this.endDate,
    this.maxMember,
    this.status,
    this.isPublished,
    this.transports,
  });
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

final class GetSavedToTrips extends TripEvent {
  final String userId;
  final int id;
  final String type;
  GetSavedToTrips({
    required this.userId,
    required this.id,
    required this.type,
  });
}
