part of 'trip_review_bloc.dart';

@immutable
sealed class TripReviewEvent {}


class GetTripReviews extends TripReviewEvent {
  final String tripId;
  final String sortType;

  GetTripReviews({
    required this.tripId,
    this.sortType = 'latest',
  });
}

class UpsertTripReview extends TripReviewEvent {
  final String tripId;
  final String? review;
  final double rating;
  final int memberId;

  UpsertTripReview({
    required this.tripId,
    this.review,
    required this.memberId,
    required this.rating,
  });
}

class DeleteTripReview extends TripReviewEvent {
  final int id;

  DeleteTripReview({
    required this.id,
  });
}
