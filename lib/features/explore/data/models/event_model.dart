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
       super.latitude,
       super.longitude,
      required super.venue,
      required super.address});

  factory EventModel.fromJson(Map<String, dynamic> jsonn) {
    return EventModel(
      id: jsonn['id'],
      name: jsonn['name'],
      image: jsonn['imageUrl'],
      price: jsonn['price'],
      isFree: jsonn['is_free'],
      orgLogo: jsonn['orgLogoUrl'],
      deepLink: jsonn['deepLink'],
      day: jsonn['day'],
      venue: jsonn['venue'],
      address: jsonn['address'],
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
    String? venue,
    String? address,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      day: day ?? this.day,
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
