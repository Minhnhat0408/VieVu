import 'package:vn_travel_companion/features/explore/data/models/location_model.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';

class TripLocationModel extends TripLocation {
  TripLocationModel({
    required super.id,
    required super.tripId,
    required super.location,
    required super.isStartingPoint,
    required super.createdAt,
  });

  factory TripLocationModel.fromJson(Map<String, dynamic> json) {
    return TripLocationModel(
      id: json['id'],
      tripId: json['trip_id'],
      location: LocationModel.fromJson(json['locations']),
      isStartingPoint: json['is_starting_point'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
