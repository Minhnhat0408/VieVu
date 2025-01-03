class Service {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String cover;
  final double score;
  final int commentCount;
  final int aggreationCommentCount;
  final List<dynamic>? tagInfoList;
  final double? avgPrice;
  final double? distance;
  final String? distanceDesc;
  final String? hotScore;
  final double? star;
  final String jumpUrl;
  final Map<String, dynamic>? statusInfo;

  const Service({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cover,
    required this.score,
    required this.commentCount,
    required this.aggreationCommentCount,
    this.tagInfoList,
    required this.avgPrice,
    this.distance,
    this.distanceDesc,
    required this.jumpUrl,
    this.star,
    this.hotScore,
    this.statusInfo,
  });
}
