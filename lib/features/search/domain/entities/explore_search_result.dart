class ExploreSearchResult {
  final String title;
  final String? address;
  final int id;
  final String? externalLink;
  final String type;
  final String? locationName;
  final int? price;
  final String? cover;
  final int? ratingCount;
  final double? avgRating;
  final double? hotScore;
  bool isSaved;

  ExploreSearchResult({
    required this.title,
    this.locationName,
    this.price,
    this.externalLink,
    required this.isSaved,
    this.address,
    required this.id,
    required this.type,
    this.cover,
    this.ratingCount,
    this.avgRating,
    this.hotScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'id': id,
      'externalLink': externalLink,
      'type': type,
      'locationName': locationName,
      'price': price,
      'cover': cover,
      'ratingCount': ratingCount,
      'avgRating': avgRating,
      'hotScore': hotScore,
      'isSaved': isSaved,
    };
  }
}
