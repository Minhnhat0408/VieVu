import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';

class TripMemberModel extends TripMember {
  TripMemberModel({
    required super.user,
    required super.role,
    required super.isBanned,
    required super.tripId,
  });

  factory TripMemberModel.fromJson(Map<String, dynamic> json) {
    return TripMemberModel(
      user: UserModel.fromJson(json['profiles']),
      role: json['role'],
      isBanned: json['is_banned'] ?? false,
      tripId: json['trip_id'],
    );
  }

  TripMemberModel copyWith({
    UserModel? user,
    String? role,
    bool? isBanned,
    String? tripId,
  }) {
    return TripMemberModel(
      user: user ?? this.user,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      tripId: tripId ?? this.tripId,
    );
  }
}
