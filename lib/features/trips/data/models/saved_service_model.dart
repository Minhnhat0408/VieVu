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
      tripId: json['tripId'],
      typeId: json['typeId'],
      cover: json['cover'],
      createdAt: json['createdAt'],
      locationName: json['locationName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['rating'],
      hotelStar: json['hotelStar'],
      ratingCount: json['ratingCount'],
      externalLink: json['externalLink'],
      tagInforList: json['tagInforList'] != null
          ? (json['tagInforList'] as List<dynamic>)
              .map((v) => v.toString())
              .toList()
          : <String>[],
    );
  }
}
