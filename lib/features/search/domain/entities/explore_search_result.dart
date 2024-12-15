class ExploreSearchResult {
  final String title;
  final String? address;
  final String id;
  final String type;
  final String? cover;

  ExploreSearchResult({
    required this.title,
    this.address,
    required this.id,
    required this.type,
    this.cover,
  });
}
