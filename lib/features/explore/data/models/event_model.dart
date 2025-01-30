import 'package:vn_travel_companion/features/explore/domain/entities/event.dart';

class EventModel extends Event {
  EventModel(
      {required super.id,
      required super.name,
      required super.image,
      required super.price,
      required super.isFree,
      required super.orgLogo,
      required super.day,
      required super.deepLink,
      required super.isSaved,
      super.latitude,
      super.longitude,
      required super.venue,
      required super.address});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      day: json['day'] ?? '',
      price: json['price'] ?? 0,
      isFree: json['isFree'] ?? false,
      orgLogo: json['orgLogoUrl'] ?? '',
      deepLink: json['deeplink'] ?? '',
      image: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      isSaved: json['isSaved'] ?? false,
      venue: json['venue'] ?? '',
      address: json['address'] ?? '',
    );
  }

  factory EventModel.fromEventDetails(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      day: json['startTime'] ?? '',
      price: json['minTicketPrice'] ?? 0,
      isFree: json['isFree'] ?? false,
      orgLogo: json['orgLogoURL'] ?? '',
      deepLink: json['deeplink'] ?? '',
      isSaved: json['isSaved'] ?? false,
      image: json['bannerURL'] ?? '',
      name: json['title'] ?? '',
      venue: json['venue'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  EventModel copyWith({
    int? id,
    String? name,
    String? image,
    int? price,
    bool? isFree,
    String? orgLogo,
    String? deepLink,
    double? latitude,
    String? day,
    double? longitude,
    bool? isSaved,
    String? venue,
    String? address,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      day: day ?? this.day,
      isSaved: isSaved ?? this.isSaved,
      isFree: isFree ?? this.isFree,
      orgLogo: orgLogo ?? this.orgLogo,
      deepLink: deepLink ?? this.deepLink,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      venue: venue ?? this.venue,
      address: address ?? this.address,
    );
  }
}
