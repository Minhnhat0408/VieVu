import 'package:vn_travel_companion/features/trips/data/models/saved_service_model.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';

class TripItineraryModel extends TripItinerary {
  TripItineraryModel({
    required super.id,
    required super.tripId,
    required super.service,
    required super.latitude,
    required super.longitude,
    required super.title,
    super.note,
    required super.time,
    required super.createdAt,
  });

  factory TripItineraryModel.fromJson(Map<String, dynamic> json) {
    return TripItineraryModel(
      id: json['id'],
      tripId: json['trip_id'],
      service: json['saved_services'] != null
          ? SavedServiceModel.fromJson(json['saved_services'])
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      title: json['title'],
      note: json['note'],
      time: DateTime.parse(json['time']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
