import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';

class TripLocation {
  final int id;
  final String tripId;
  final Location location;
  final bool isStartingPoint;
  final DateTime createdAt;

  TripLocation({
    required this.id,
    required this.tripId,
    required this.location,
    required this.isStartingPoint,
    required this.createdAt,
  });
}
