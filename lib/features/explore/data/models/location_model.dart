import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';

class LocationModel extends Location {
  LocationModel({
    required super.id,
    required super.name,
    required super.images,
    required super.ename,
    required super.cover,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.childLoc,
    super.parentId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> jsonn) {
    return LocationModel(
      id: jsonn['id'],
      name: jsonn['name'],
      images: jsonn['images'] != null
          ? (jsonn['images'] as List<dynamic>).map((v) => v.toString()).toList()
          : <String>[],
      ename: jsonn['ename'],
      cover: jsonn['cover'],
      latitude: jsonn['latitude'].toDouble(),
      longitude: jsonn['longitude'].toDouble(),
      parentId: jsonn['parent_id'],
      address: jsonn['address'] ?? '',
      childLoc: jsonn['childLoc'] ?? <LocationModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'ename': ename,
      'cover': cover,
      'latitude': latitude,
      'longitude': longitude,
      'parent_id': parentId,
      'address': address,
    };
  }

  LocationModel copyWith({
    int? id,
    String? name,
    List<String>? images,
    String? ename,
    String? cover,
    double? latitude,
    double? longitude,
    int? parentId,
    String? address,
    List<LocationModel>? childLoc,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      ename: ename ?? this.ename,
      cover: cover ?? this.cover,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parentId: parentId ?? this.parentId,
      address: address ?? this.address,
      childLoc: childLoc ?? this.childLoc,
    );
  }
}
