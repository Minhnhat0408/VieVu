import 'package:vievu/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.id,
      required super.email,
      required super.firstName,
      required super.lastName,
      required super.tripCount,
      required super.ratingCount,
      required super.avgRating,
      super.latitude,
      super.longitude,
      super.avatarUrl,
      super.city,
      super.bio,
      super.gender,
      super.phoneNumber});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: json['avatar_url'],
      tripCount: json['trip_count'] ?? 0,
      ratingCount: json['rating_count'] ?? 0,
      avgRating: json['avg_rating'] ?? 0.0,
      latitude: json['latitude'],
      longitude: json['longitude'],
      bio: json['bio'],
      city: json['city'],
      gender: json['gender'],
      phoneNumber: json['phone'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? city,
    double? latitude,
    double? longitude,
    int? tripCount,
    int? ratingCount,
    double? avgRating,
    String? gender,
    String? phoneNumber,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      tripCount: tripCount ?? this.tripCount,
      ratingCount: ratingCount ?? this.ratingCount,
      avgRating: avgRating ?? this.avgRating,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class UserPositionModel extends UserPosition {
  UserPositionModel({
    required super.id,
    required super.latitude,
    required super.longitude,
  });

  factory UserPositionModel.fromJson(Map<String, dynamic> json) {
    return UserPositionModel(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
