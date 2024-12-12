import 'dart:convert';

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
      required super.travelTypes,
      super.ename,
      super.images,
      super.price,
      super.rankInfo,
      super.address,
      super.openTimeRule,
      super.phone,
      super.avgRating,
      super.ratingCount});

  factory AttractionModel.fromJson(Map<String, dynamic> jsonn) {
    return AttractionModel(
      id: jsonn['id'],
      name: jsonn['name'],
      ename: jsonn['ename'] ?? '',
      cover: jsonn['cover'],
      images: jsonn['images'] != null
          ? (jsonn['images'] as List<dynamic>).map((v) => v.toString()).toList()
          : <String>[],
      hotScore: jsonn['hot_score'].toDouble(),
      price: jsonn['price'],
      rankInfo: jsonn['rank_info'],
      latitude: jsonn['latitude'].toDouble(),
      longitude: jsonn['longitude'].toDouble(),
      address: jsonn['address'],
      locationId: jsonn['location_id'],
      openTimeRule: jsonn['open_time_rule'],
      description: jsonn['description'].toString(),
      phone: jsonn['phone'],
      avgRating:
          jsonn['avg_rating'] != null ? jsonn['avg_rating'].toDouble() : 0,
      ratingCount: jsonn['rating_count'],
      travelTypes: jsonn['attraction_types'],
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
    );
  }
}
