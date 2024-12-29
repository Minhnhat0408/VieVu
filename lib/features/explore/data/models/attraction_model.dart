import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';

class AttractionModel extends Attraction {
  AttractionModel(
      {required super.id,
      required super.name,
      required super.cover,
      required super.hotScore,
      required super.latitude,
      required super.longitude,
      required super.locationId,
      required super.description,
      super.travelTypes,
      super.ename,
      super.images,
      super.price,
      super.rankInfo,
      super.address,
      super.openTimeRule,
      super.phone,
      super.avgRating,
      super.ratingCount,
      super.distance});

  factory AttractionModel.fromJson(Map<String, dynamic> jsonn) {
    return AttractionModel(
      id: jsonn['id'],
      name: jsonn['name'],
      ename: jsonn['ename'] ?? '',
      cover: jsonn['cover'],
      images: jsonn['images'] != null
          ? (jsonn['images'] as List<dynamic>).map((v) => v.toString()).toList()
          : <String>[],
      hotScore:
          jsonn['hot_score'] != null ? jsonn['hot_score'].toDouble() : 0.0,
      price: _parseInt(jsonn['price']),
      rankInfo: null,
      latitude: jsonn['latitude'] != null ? jsonn['latitude'].toDouble() : 0.0,
      longitude:
          jsonn['longitude'] != null ? jsonn['longitude'].toDouble() : 0.0,
      address: jsonn['address'],
      locationId: jsonn['location_id'],
      openTimeRule:
          jsonn['open_time_rule'] is List ? jsonn['open_time_rule'] : [],
      description: jsonn['description']?.toString() ?? '',
      phone: jsonn['phone'],
      avgRating:
          jsonn['avg_rating'] != null ? jsonn['avg_rating'].toDouble() : 0.0,
      ratingCount: _parseInt(jsonn['rating_count']),
      travelTypes:
          jsonn['attraction_types'] is List ? jsonn['attraction_types'] : [],
      distance: jsonn['distance'] != null ? jsonn['distance'].toDouble() : 0.0,
    );
  }

  factory AttractionModel.fromGeneralLocationInfo(Map<String, dynamic> json) {
    return AttractionModel(
      id: json['id'] ?? 0,
      name: json['name'],
      ename: json['ename'] ?? '',
      cover: json['imageUrl'],
      images: json['images'] != null
          ? (json['images'] as List<dynamic>).map((v) => v.toString()).toList()
          : null,
      hotScore: json['hot_score'] != null ? json['hot_score'].toDouble() : 0.0,
      price: _parseInt(json['price']),
      rankInfo: null,
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : 0.0,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : 0.0,
      address: json['address'],
      locationId: json['location_id'] ?? 0,
      openTimeRule:
          json['open_time_rule'] is List ? json['open_time_rule'] : null,
      description: json['description']?.toString() ?? '',
      phone: json['phone'],
      avgRating: json['score'] ?? 0.0,
      ratingCount: _parseInt(json['commentNum']) ?? 0,
      travelTypes: json['tags'] is List
          ? json['tags']
          : json['distance'] != null
              ? [json['distance']]
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'hot_score': hotScore,
      'latitude': latitude,
      'longitude': longitude,
      'location_id': locationId,
      'description': description,
      'ename': ename,
      'images': images,
      'price': price,
      'rank_info': rankInfo,
      'address': address,
      'open_time_rule': openTimeRule,
      'phone': phone,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'travel_types': travelTypes,
      'distance': distance,
    };
  }

  AttractionModel copyWith({
    int? id,
    String? name,
    String? cover,
    double? hotScore,
    double? latitude,
    double? longitude,
    int? locationId,
    String? description,
    String? ename,
    List<String>? images,
    int? price,
    Map<String, dynamic>? rankInfo,
    String? address,
    List<Map<String, dynamic>>? openTimeRule,
    double? avgRating,
    int? ratingCount,
    String? phone,
    List<Map<String, String>>? travelTypes,
    double? distance,
  }) {
    return AttractionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ename: ename ?? this.ename,
      cover: cover ?? this.cover,
      images: images ?? this.images,
      hotScore: hotScore ?? this.hotScore,
      price: price ?? this.price,
      rankInfo: rankInfo ?? this.rankInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      locationId: locationId ?? this.locationId,
      openTimeRule: openTimeRule ?? this.openTimeRule,
      description: description ?? this.description,
      phone: phone ?? phone,
      avgRating: avgRating ?? this.avgRating,
      ratingCount: ratingCount ?? this.ratingCount,
      travelTypes: travelTypes ?? this.travelTypes,
      distance: distance ?? this.distance,
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) {
    if (value == 0.0) {
      return null;
    }
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  return null; // Return null if parsing fails
}
