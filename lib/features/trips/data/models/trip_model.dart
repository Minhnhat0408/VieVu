import 'package:vievu/features/auth/data/models/user_model.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required super.id,
    required super.name,
    super.description,
    super.startDate,
    super.endDate,
    required super.createdAt,
    super.maxMember,
    super.user,
    required super.status,
    required super.isPublished,
    required super.locations,
    super.transports,
    required super.isSaved,
    required super.hasTripItineraries,
    super.cover,
    required super.serviceCount,
    required super.rating,
    super.publishedTime,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // convert json['created_at'] from string to DateTime
    // convert json['start_date'] from string to DateTime
    // convert json['end_date'] from string to DateTime
    return TripModel(
      id: json['id'] ?? "",
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      isSaved: json['is_saved'] ?? false,
      name: json['name'] ?? "",
      hasTripItineraries: json['has_trip_itineraries'] ?? false,
      cover: json['cover'],
      serviceCount: json['service_count'] ?? 0,
      description: json['description'],
      publishedTime: json['published_time'] != null
          ? DateTime.parse(json['published_time'])
          : null,
      transports: json['transports'] != null
          ? (json['transports'] as List<dynamic>)
              .map((v) => v.toString())
              .toList()
          : null,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] == null ? null : DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
      maxMember: json['max_member'],
      user: json['profiles'] != null
          ? UserModel.fromJson(json['profiles'])
          : null,
      status: json['status'],
      isPublished: json['is_published'] ?? false,
      locations:
          json['locations'] != null ? List<String>.from(json['locations']) : [],
    );
  }
}
