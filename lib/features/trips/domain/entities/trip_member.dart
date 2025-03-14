import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';

class TripMember {
  final User user;
  final String role;
  final bool isBanned;
  final String tripId;


  TripMember({
    required this.user,
    required this.role,
    required this.isBanned,

    required this.tripId,
  });

  //from json
  // factory TripMember.fromJson(Map<String, dynamic> json) {
  //   return TripMember(
  //     user: User.fromJson(json['profiles']),
  //     role: json['role'],
  //     isBanned: json['is_banned'] ?? false,
  //     tripId: json['trip_id'],

  //   );
  // }

  // tojson
  Map<String, dynamic> toJson() {
    return {
      'profiles': user.toJson(),
      'role': role,
      'is_banned': isBanned,
      'trip_id': tripId,
    
    };
  }
}
