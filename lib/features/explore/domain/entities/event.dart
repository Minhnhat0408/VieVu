class Event {
  final int id;
  final String name;
  final String image;
  final int price;
  final bool isFree;
  final String orgLogo;
  final String deepLink;
  final String day;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int? locationId;
  bool isSaved;
  final String venue;
  final String address;

  Event({
    required this.id,
    required this.name,
    required this.image,
    required this.day,
    required this.price,
    required this.isFree,
    required this.isSaved,
    required this.orgLogo,
    required this.deepLink,
    this.locationId,
    this.locationName,
    this.latitude,
    this.longitude,
    required this.venue,
    required this.address,
  });
}
