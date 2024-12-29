class Hotel {
  final int id;
  final String name;
  final String cover;
  final String address;
  final int star;
  final int price;
  final double avgRating;
  final int ratingCount;
  final double latitude;
  final double longitude;
  final String roomName;
  final String positionDesc;
  final int adultCount;
  final int childCount;
  final String roomDesc;
  final List<String>? additionalDesc;
  final String jumpUrl;

  const Hotel({
    required this.id,
    required this.name,
    required this.cover,
    required this.price,
    required this.address,
    required this.star,
    required this.avgRating,
    required this.ratingCount,
    required this.latitude,
    required this.longitude,
    required this.roomName,
    required this.positionDesc,
    required this.adultCount,
    required this.childCount,
    required this.roomDesc,
    this.additionalDesc,
    required this.jumpUrl,
  });
}
