class Attraction {
  final int id;
  final String name;
  final String? ename;
  final String cover;
  final List<String>? images;
  final double hotScore;
  final int? price;
  final Map<String, dynamic>? rankInfo;
  final double latitude;
  final double longitude;
  final String? address;
  final int locationId;
  final List<dynamic>? openTimeRule;
  final String description;
  final String? phone;
  final double? avgRating;
  final int? ratingCount;
  final List<dynamic> travelTypes;

  const Attraction({
    required this.id,
    required this.name,
    this.ename,
    required this.cover,
    this.images,
    required this.hotScore,
    required this.travelTypes,
    this.price,
    this.rankInfo,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.locationId,
    this.openTimeRule,
    required this.description,
    this.phone,
    this.avgRating,
    this.ratingCount,
  });
}
