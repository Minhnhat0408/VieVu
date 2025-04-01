import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/trips/domain/entities/trip_review.dart';

class TripReviewModel extends TripReview {
  TripReviewModel({
    required super.id,
    required super.tripId,
    required super.user,
    required super.memberId,
    super.review,
    required super.rating,
    required super.createdAt,
  });

  factory TripReviewModel.fromJson(Map<String, dynamic> json) {
    return TripReviewModel(
      id: json['id'] ?? 0,
      tripId: json['trip_id'],
      user: User.fromJson(json['trip_participants']['profiles']),
      memberId: json['trip_participant_id'],
      review: json['review'],
      rating: json['rating'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'user': user.toJson(),
      'memberId': memberId,
      'review': review,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
