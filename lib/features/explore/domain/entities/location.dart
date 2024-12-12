class Location {
  final int id;
  final String name;
  final List<String> images;
  final String ename;
  final String cover;
  final double latitude;
  final double longitude;
  final int? parentId;

  const Location({
    required this.id,
    required this.name,
    required this.images,
    required this.ename,
    required this.cover,
    required this.latitude,
    required this.longitude,
    this.parentId,
  });
}
