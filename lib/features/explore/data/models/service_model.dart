import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';

class ServiceModel extends Service {
  ServiceModel({
    required super.id,
    required super.name,
    required super.typeId,
    required super.latitude,
    required super.longitude,
    required super.cover,
    required super.score,
    required super.commentCount,
    required super.aggreationCommentCount,
    super.tagInfoList,
    required super.isSaved,
    super.avgPrice,
    super.distance,
    super.distanceDesc,
    required super.jumpUrl,
    super.eventDate,
    super.star,
    super.hotScore,
  });

  factory ServiceModel.fromRestaurantJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
      typeId: json['typeId'],
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      cover: json['image'],
      score: json['score'],
      isSaved: json['isSaved'] ?? false,
      commentCount: json[' commentCount'] ?? 0,
      aggreationCommentCount: json['aggreationCommentCount'],
      tagInfoList: json['tagInfoList'],
      avgPrice: json['avgPrice'],
      distance: json['distance'],
      distanceDesc: json['distanceDesc'],
      jumpUrl: json['jumpUrl'],
    );
  }

  factory ServiceModel.fromHotelJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
      isSaved: json['isSaved'] ?? false,
      typeId: json['typeId'],
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      cover: json['image'],
      score: json['score'],
      commentCount: json['commentCount'],
      aggreationCommentCount: json['aggreationCommentCount'],
      tagInfoList: json['tagInfoList'],
      avgPrice: json['minPrice'],
      distance: json['distance'],
      distanceDesc: json['distanceDesc'],
      jumpUrl: json['jumpUrl'],
      star: json['star'],
    );
  }

  factory ServiceModel.fromShopJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
      typeId: json['typeId'],
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      isSaved: json['isSaved'] ?? false,
      cover: json['image'],
      score: json['score'],
      commentCount: json['commentCount'],
      aggreationCommentCount: json['aggreationCommentCount'],
      tagInfoList: json['tagInfoList'],
      distance: json['distance'],
      distanceDesc: json['distanceDesc'],
      jumpUrl: json['jumpUrl'],
    );
  }

  factory ServiceModel.fromAttractionJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
      typeId: json['typeId'],
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      cover: json['image'],
      isSaved: json['isSaved'] ?? false,
      score: json['score'],
      commentCount: json['commentCount'],
      aggreationCommentCount: json['aggreationCommentCount'],
      tagInfoList: json['tagInfoList'],
      avgPrice: json['minPrice'],
      distance: json['distance'],
      distanceDesc: json['distanceDesc'],
      jumpUrl: json['jumpUrl'],
      hotScore: json['hotScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'cover': cover,
      'score': score,
      'commentCount': commentCount,
      'aggreationCommentCount': aggreationCommentCount,
      'tagInfoList': tagInfoList,
      'avgPrice': avgPrice,
      'distance': distance,
      'distanceDesc': distanceDesc,
      'jumpUrl': jumpUrl,
      'star': star,
    };
  }

  ServiceModel copyWith({
    int? id,
    bool? isSaved,
    String? name,
    int? typeId,
    double? latitude,
    double? longitude,
    String? cover,
    double? score,
    int? commentCount,
    int? aggreationCommentCount,
    List<String>? tagInfoList,
    double? avgPrice,
    double? distance,
    String? distanceDesc,
    String? jumpUrl,
    DateTime? eventDate,
    double? star,
    String? hotScore,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      typeId: typeId ?? this.typeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cover: cover ?? this.cover,
      isSaved: isSaved ?? this.isSaved,
      score: score ?? this.score,
      commentCount: commentCount ?? this.commentCount,
      aggreationCommentCount:
          aggreationCommentCount ?? this.aggreationCommentCount,
      tagInfoList: tagInfoList ?? this.tagInfoList,
      avgPrice: avgPrice ?? this.avgPrice,
      distance: distance ?? this.distance,
      distanceDesc: distanceDesc ?? this.distanceDesc,
      jumpUrl: jumpUrl ?? this.jumpUrl,
      star: star ?? this.star,
      hotScore: hotScore ?? this.hotScore,
    );
  }
}
