// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender; //TODO: Change to ENUM
  final String? phoneNumber;
  final String? bio;
  final String? avatarUrl;
  final String? city;
  final int tripCount;
  final int ratingCount;
  final double avgRating;
  double? longitude;
  double? latitude;
  
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
     this.latitude,
    this.longitude,
    required this.tripCount,
    required this.ratingCount,
    required this.avgRating,
    this.avatarUrl,
    this.bio,
    this.city,
    this.gender,
    this.phoneNumber,
  });
  //fromjson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: json['avatar_url'],
      tripCount: json['trip_count'] ?? 0,
      ratingCount: json['rating_count'] ?? 0,
      avgRating: json['avg_rating'] ?? 0.0,
      bio: json['bio'],
      city: json['city'],
      phoneNumber: json['phone'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  // tojson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phoneNumber,
      'avatar_url': avatarUrl,
      'first_name': firstName,
      'last_name': lastName,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}

class UserPosition {
  final String id;
  final double latitude;
  final double longitude;

  UserPosition({
    required this.id,
    required this.latitude,
    required this.longitude,
  });
}
