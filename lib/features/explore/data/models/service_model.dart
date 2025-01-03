import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';

class ServiceModel extends Service {
  ServiceModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.cover,
    required super.score,
    required super.commentCount,
    required super.aggreationCommentCount,
    super.tagInfoList,
    super.avgPrice,
    super.distance,
    super.distanceDesc,
    required super.jumpUrl,
    super.star,
    super.hotScore,
    super.statusInfo,
  });

  factory ServiceModel.fromRestaurantJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      cover: json['image'],
      score: json['score'],
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
      latitude: json['coordinate']['latitude'],
      longitude: json['coordinate']['longitude'],
      cover: json['image'],
      score: json['score'],
      commentCount: json['commentCount'],
      aggreationCommentCount: json['aggreationCommentCount'],
      tagInfoList: json['tagInfoList'],
      distance: json['distance'],
      distanceDesc: json['distanceDesc'],
      jumpUrl: json['jumpUrl'],
      statusInfo: json['statusInfo'] as Map<String, dynamic>?,
    );
  }

  factory ServiceModel.fromAttractionJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['poiId'],
      name: json['name'],
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
}
