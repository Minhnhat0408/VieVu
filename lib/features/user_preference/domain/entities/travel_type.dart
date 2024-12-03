class TravelType {
  final String id;
  final String name;
  final String? parentId;

TravelType({
    required this.id,
    required this.name,
    this.parentId,
  });
}
