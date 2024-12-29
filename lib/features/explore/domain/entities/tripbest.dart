class TripBest {
  final  int id;
  final  String title;
  final int totalCount;
  final String businessType;
  final String cover;
  final String jumpUrl;

  const TripBest({
    required this.id,
    required this.title,
    required this.totalCount,
    required this.businessType,
    required this.cover,
    required this.jumpUrl,
  });

  factory TripBest.fromJson(Map<String, dynamic> json) {
    return TripBest(
      id: json['rankId'],
      title: json['title'],
      totalCount: json['totalCount'],
      businessType: json['businessType'],
      cover: json['imageUrl'],
      jumpUrl: json['jumpUrl'],
    );
  }
}