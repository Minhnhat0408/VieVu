
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';

class HotelModel extends Hotel {
  HotelModel({
    required super.id,
    required super.isSaved,
    required super.name,
    required super.cover,
    required super.address,
    required super.star,
    required super.avgRating,
    required super.ratingCount,
    required super.price,
    required super.latitude,
    required super.longitude,
    required super.roomName,
    required super.positionDesc,
    required super.adultCount,
    required super.childCount,
    required super.roomDesc,
    required super.jumpUrl,
    super.additionalDesc,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final count = json['commentInfo']['commenterNumber'] != null &&
            json['commentInfo']['commenterNumber'].contains(' ')
        ? int.tryParse(json['commentInfo']['commenterNumber'].split(' ')[0]) ??
            0
        : 0;

    final cityNameEn = json['positionInfo']['cityNameEn'] as String;

    final normalizedCityNameEn = cityNameEn.replaceAll(' ', '-').toLowerCase();
    final link =
        'https://vn.trip.com/hotels/$normalizedCityNameEn-hotel-detail-${json['hotelBasicInfo']['hotelId']}';
    return HotelModel(
      id: json['hotelBasicInfo']['hotelId'],
      name: json['hotelBasicInfo']['hotelName'] ?? '',
      cover: json['hotelBasicInfo']['hotelImg'] ?? '',
      address: json['hotelBasicInfo']['hotelAddress'] ?? '',
      price: json['hotelBasicInfo']['price'] is int
          ? json['hotelBasicInfo']['price']
          : 0,
      star: json['hotelStarInfo']['star'],
      isSaved: json['isSaved'] ?? false,
      avgRating:
          double.tryParse(json['commentInfo']['commentScore'] ?? '0') ?? 0.0,
      ratingCount: count,
      latitude: json['positionInfo']['coordinate']['lat'],
      longitude: json['positionInfo']['coordinate']['lng'],
      roomName:
          json['roomInfo'] != null ? json['roomInfo']['physicalRoomName'] : '',
      positionDesc: json['positionInfo']['positionInfo'],
      adultCount:
          json['hotelBasicInfo']?['guestInfoEntity']?['adultCount'] != null
              ? json['hotelBasicInfo']['guestInfoEntity']['adultCount']
              : 0,
      childCount:
          json['hotelBasicInfo']?['guestInfoEntity']?['childCount'] != null
              ? json['hotelBasicInfo']['guestInfoEntity']['childCount']
              : 0,
      roomDesc: json['roomInfo'] != null
          ? json['roomInfo']['bed']["contentList"][0]
          : '',
      additionalDesc: json['additionalDesc'] != null
          ? List<String>.from(json['additionalDesc'])
          : null,
      jumpUrl: link,
    );
  }

  factory HotelModel.fromGeneralLocationInfo(Map<String, dynamic> json) {
    return HotelModel(
      id: json['hotelId'],
      name: json['hotelName'],
      isSaved: json['isSaved'] ?? false,
      cover: json['imageUrl'],
      address: json['hotelAddress'] ?? '',
      price: json['price'] ?? 0,
      star: json['star'],
      avgRating: json['score'],
      ratingCount: json['commentNum'] is int
          ? json['commentNum']
          : int.parse(json['commentNum']),
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      roomName: json['roomName'] ?? '',
      positionDesc: json['positionDesc'] ?? '',
      adultCount: json['adultCount'] ?? 0,
      childCount: json['childCount'] ?? 0,
      jumpUrl: json['jumpUrl'],
      roomDesc: json['roomDesc'] ?? '',
      additionalDesc: json['additionalDesc'] != null
          ? List<String>.from(json['additionalDesc'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'address': address,
      'star': star,
      'avgRating': avgRating,
      'ratingCount': ratingCount,
      'latitude': latitude,
      'longitude': longitude,
      'roomName': roomName,
      'positionDesc': positionDesc,
      'adultCount': adultCount,
      'childCount': childCount,
      'roomDesc': roomDesc,
      'additionalDesc': additionalDesc,
    };
  }

  HotelModel copyWith({
    int? id,
    String? name,
    String? cover,
    String? address,
    int? star,
    int? price,
    bool? isSaved,
    double? avgRating,
    int? ratingCount,
    double? latitude,
    double? longitude,
    String? roomName,
    String? positionDesc,
    int? adultCount,
    int? childCount,
    String? roomDesc,
    List<String>? additionalDesc,
    String? jumpUrl,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      address: address ?? this.address,
      isSaved: isSaved ?? this.isSaved,
      star: star ?? this.star,
      price: price ?? this.price,
      avgRating: avgRating ?? this.avgRating,
      ratingCount: ratingCount ?? this.ratingCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      roomName: roomName ?? this.roomName,
      positionDesc: positionDesc ?? this.positionDesc,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      roomDesc: roomDesc ?? this.roomDesc,
      additionalDesc: additionalDesc ?? this.additionalDesc,
      jumpUrl: jumpUrl ?? this.jumpUrl,
    );
  }
}
