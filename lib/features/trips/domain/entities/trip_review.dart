import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';

class TripReview {
  final int id;
  final String tripId;
  final User user;
  final int memberId;
  final String? review;
  final double rating;
  final DateTime createdAt;

  TripReview({
    required this.id,
    required this.tripId,
    required this.user,
    required this.memberId,
    this.review,
    required this.rating,
    required this.createdAt,
  });
}
