import 'package:vievu/features/auth/data/models/user_model.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';

class TripMemberModel extends TripMember {
  TripMemberModel({
    required super.user,
    required super.role,
    required super.isBanned,
    required super.tripId,
    required super.id,
    required super.reviewed,
    required super.rating,
  });

  factory TripMemberModel.fromJson(Map<String, dynamic> json) {
    return TripMemberModel(
      user: UserModel.fromJson(json['profiles']),
      role: json['role'],
      isBanned: json['is_banned'] ?? false,
      tripId: json['trip_id'],
      reviewed: json['reviewed'] ?? false,
      id: json['id'],
      rating: json['rating'] ?? 0,
    );
  }

  TripMemberModel copyWith({
    UserModel? user,
    String? role,
    bool? isBanned,
    String? tripId,
    double? longitude,
    double? latitude,
    bool? reviewed,
    int? id,
    int? rating,
  }) {
    return TripMemberModel(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      reviewed: reviewed ?? this.reviewed,
      user: user ?? this.user,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      tripId: tripId ?? this.tripId,
    );
  }
}

class TripMemberRatingModel extends TripMemberRating {
  TripMemberRatingModel({
    required super.user,
    required super.rating,
    required super.tripName,
    required super.tripId,
    required super.tripCover,
  });

  factory TripMemberRatingModel.fromJson(Map<String, dynamic> json) {
    return TripMemberRatingModel(
      user: UserModel.fromJson(json['profiles']),
      rating: json['rating'],
      tripId: json['trip_id'] ?? "",
      tripName: json['trip_name'] ?? "",
      tripCover: json['trip_cover'] ?? "",
    );
  }

  TripMemberRatingModel copyWith({
    UserModel? user,
    int? rating,
    String? tripName,
    String? tripId,
    String? tripCover,
  }) {
    return TripMemberRatingModel(
      user: user ?? this.user,
      rating: rating ?? this.rating,
      tripName: tripName ?? this.tripName,
      tripId: tripId ?? this.tripId,
      tripCover: tripCover ?? this.tripCover,
    );
  }
}
