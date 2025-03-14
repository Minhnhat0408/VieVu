part of 'trip_itinerary_bloc.dart';

@immutable
sealed class TripItineraryEvent {}

class InsertTripItinerary extends TripItineraryEvent {
  final String tripId;
  final int? serviceId;
  final double latitude;
  final double longitude;
  final String title;
  final String? note;
  final DateTime time;

  InsertTripItinerary({
    required this.tripId,
    this.serviceId,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.note,
    required this.time,
  });
}

class GetTripItineraries extends TripItineraryEvent {
  final String tripId;

  GetTripItineraries({
    required this.tripId,
  });
}

class UpdateTripItinerary extends TripItineraryEvent {
  final int id;
  final String? note;
  final DateTime? time;
  final bool? isDone;

  UpdateTripItinerary({
    required this.id,
    this.note,
    this.isDone,
    this.time,
  });
}

class DeleteTripItinerary extends TripItineraryEvent {
  final int itineraryId;

  DeleteTripItinerary({
    required this.itineraryId,
  });
}
