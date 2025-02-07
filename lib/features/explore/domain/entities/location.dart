import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/comment.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/tripbest.dart';

class Location {
  final int id;
  final String name;
  final List<String> images;
  final String ename;
  final String cover;
  final double latitude;
  final double longitude;
  final int? parentId;
  final List<Location> childLoc;
  final String address;

  const Location({
    required this.id,
    required this.name,
    required this.images,
    required this.ename,
    required this.cover,
    required this.latitude,
    required this.longitude,
    required this.childLoc,
    this.parentId,
    required this.address,
  });
}



class GenericLocationInfo {
   List<Attraction> attractions;
   List<Hotel> hotels;
   List<Restaurant> restaurants;
   List<TripBest>? tripbestModule;
   List<Comment>? comments;
   List<Location>? locations;

  GenericLocationInfo({
    required this.attractions,
    required this.hotels,
    required this.restaurants,
    this.comments,
    this.tripbestModule,
    this.locations,
  });

  GenericLocationInfo copyWith({
    List<Attraction>? attractions,
    List<Hotel>? hotels,
    List<Restaurant>? restaurants,
    List<TripBest>? tripbestModule,
    List<Comment>? comments,
    List<Location>? locations,
  }) {
    return GenericLocationInfo(
      attractions: attractions ?? this.attractions,
      hotels: hotels ?? this.hotels,
      restaurants: restaurants ?? this.restaurants,
      tripbestModule: tripbestModule ?? this.tripbestModule,
      comments: comments ?? this.comments,
      locations: locations ?? this.locations,
    );
  }
}


class GeoApiLocation {
  final double latitude;
  final double longitude;
  final String address;
  final int id;
  final String cityName;

  GeoApiLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.id,
    required this.cityName,
  });
}
