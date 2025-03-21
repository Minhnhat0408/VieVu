class HomeSearchResult {
  final String id;
  final String name;
  final String? cover;
  final String type;
  final String? locations;

  HomeSearchResult({
    required this.id,
    required this.name,
    required this.cover,
    required this.type,
    this.locations,
  });
}
