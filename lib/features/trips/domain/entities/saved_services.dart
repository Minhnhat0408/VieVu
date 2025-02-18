class SavedService {
  final DateTime createdAt;
  final int id;
  final int dbId;
  final String tripId;
  final String? externalLink;
  final double latitude;
  final double longitude;
  final String cover;
  final String name;
  final int typeId;
  final DateTime? eventDate;
  final String locationName;
  final List<String>? tagInforList;
  final double rating;
  final int? price;
  final int? hotelStar;
  final int ratingCount;


  SavedService({
    required this.id,
    required this.dbId,
    required this.typeId,
    required this.createdAt,
    required this.tripId,
    this.hotelStar,
    this.externalLink,
    this.eventDate,
    this.price,
    required this.cover,
    required this.name,
    required this.locationName,
    this.tagInforList,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.ratingCount,

  });
}
