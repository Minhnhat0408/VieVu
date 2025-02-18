import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';

class TripItinerary {
  final int id;
  final String tripId;
  final SavedService? service;
  final double latitude;
  final double longitude;
  final String title;
  final String? note;
  final DateTime time;

  final DateTime createdAt;

  TripItinerary({
    required this.id,
    required this.tripId,
    this.service,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.note,
    required this.time,
    required this.createdAt,
  });
}
