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
}
