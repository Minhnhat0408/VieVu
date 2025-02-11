import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';

class SavedServiceModel extends SavedService {
  SavedServiceModel({
    required super.id,
    required super.name,
    required super.tripId,
    required super.cover,
    required super.createdAt,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.ratingCount,
    super.externalLink,
    super.hotelStar,
    required super.typeId,
    super.tagInforList,
  });

  factory SavedServiceModel.fromJson(Map<String, dynamic> json) {
    return SavedServiceModel(
      id: json['id'],
      name: json['name'],
      tripId: json['trip_id'],
      typeId: json['type_id'],
      cover: json['cover'],
      createdAt: DateTime.parse(json['created_at']),
      locationName: json['location_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['avg_rating']?.toDouble() ?? 0,
      hotelStar: json['hotel_star'] ?? 0,
      ratingCount: json['rating_count'] ?? 0,
      externalLink: json['external_link'],
      tagInforList: json['tag_info_list'] != null
          ? (json['tag_info_list'] as List<dynamic>)
              .map((v) => v.toString())
              .toList()
          : null,
    );
  }
}
