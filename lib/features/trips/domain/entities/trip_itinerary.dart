import 'package:vievu/features/trips/domain/entities/saved_services.dart';

class TripItinerary {
  final int id;
  final String tripId;
  final SavedService? service;
  final double latitude;
  final double longitude;
  final String title;
  final String? note;
  bool isDone;
  DateTime time;
  final DateTime createdAt;

  TripItinerary({
    required this.id,
    required this.tripId,
    this.service,
    required this.latitude,
    required this.isDone,
    required this.longitude,
    required this.title,
    this.note,
    required this.time,
    required this.createdAt,
  });

  TripItinerary copyWith({
    int? id,
    String? tripId,
    SavedService? service,
    double? latitude,
    double? longitude,
    String? title,
    String? note,
    DateTime? time,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return TripItinerary(
      id: id ?? this.id,
      isDone: isDone ?? this.isDone,
      tripId: tripId ?? this.tripId,
      service: service ?? this.service,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      note: note ?? this.note,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
