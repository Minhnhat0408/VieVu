class ExploreSearchResult {
  final String title;
  final String? address;
  final String id;
  final String type;
  final String? cover;
  final int? ratingCount;
  final double? avgRating;
  final double? hotScore;

  ExploreSearchResult({
    required this.title,
    this.address,
    required this.id,
    required this.type,
    this.cover,
    this.ratingCount,
    this.avgRating,
    this.hotScore,
  });
}
