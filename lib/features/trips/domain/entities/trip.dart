import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';

class Trip {
  final String id;
  final String name;
  final String? description;
  final String? cover;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final int? maxMember;
  final String userId;
  final String status;
  final bool isPublished;
  final List<String> locations;
  final int serviceCount;
  final List<String>? transports;
  final bool isSaved;

  Trip({
    required this.id,
    required this.name,
    this.description,
    this.cover,
    required  this.isSaved,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.maxMember,
    required this.locations,
    required this.serviceCount,
    required this.userId,
    required this.status,
    required this.isPublished,
    this.transports,
  });
}
