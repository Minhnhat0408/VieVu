import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required super.id,
    required super.name,
    super.description,
    super.startDate,
    super.endDate,
    required super.createdAt,
    super.maxMember,
    required super.userId,
    required super.status,
    required super.isPublished,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createdAt: json['createdAt'],
      maxMember: json['maxMember'],
      userId: json['userId'],
      status: json['status'],
      isPublished: json['isPublished'],
    );
  }
}
