import 'package:vievu/features/auth/domain/entities/user.dart';

class Trip {
  final String id;
  final String name;
  final String? description;
  final String? cover;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final int? maxMember;
  final User? user;
  final String status;
  final bool isPublished;
  final List<String> locations;
  final int serviceCount;
  final List<String>? transports;
  final bool isSaved;
  final double rating;
  final DateTime? publishedTime;

  bool hasTripItineraries;

  Trip({
    required this.id,
    required this.name,
    required this.hasTripItineraries,
    this.description,
    required this.rating,
    this.cover,
    required this.isSaved,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.maxMember,
    required this.locations,
    required this.serviceCount,
    this.user,
    required this.status,
    required this.isPublished,
    this.transports,
    this.publishedTime,
  });
}
