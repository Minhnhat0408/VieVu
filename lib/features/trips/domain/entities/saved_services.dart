class SavedServices {
  final DateTime createdAt;
  final int id;
  final String tripId;
  final String? externalLink;
  final double latitude;
  final double longitude;
  final String cover;
  final String name;
  final int typeId;
  final String locationName;
  final List<String>? tagInforList;
  final double rating;
  final int? hotelStar;
  final int ratingCount;
  final int? attractionId;

  SavedServices({
    required this.id,
    required this.typeId,
    required this.createdAt,
    required this.tripId,
    this.hotelStar,
    this.externalLink,
    required this.cover,
    required this.name,
    required this.locationName,
    this.tagInforList,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.ratingCount,
    this.attractionId,
  });
}
