import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';

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
