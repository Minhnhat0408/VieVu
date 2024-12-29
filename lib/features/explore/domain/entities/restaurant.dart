class Restaurant {
  final int id;
  final String name;
  final String cover;
  final int price;
  final double latitude;
  final double longitude;
  final double avgRating;
  final int ratingCount;
  final String cuisineName;
  final String? userNickname;
  final String? userAvatar;
  final String? userContent;
  final String jumpUrl;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cover,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.avgRating,
    required this.ratingCount,
    required this.cuisineName,
    this.userNickname,
    this.userAvatar,
    this.userContent,
    required this.jumpUrl,
  });

}