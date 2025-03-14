part of 'trip_review_bloc.dart';

@immutable
sealed class TripReviewState {}

final class TripReviewInitial extends TripReviewState {}

final class TripReviewLoading extends TripReviewState {}

final class TripReviewActionLoading extends TripReviewState {}

final class TripReviewFailure extends TripReviewState {
  final String message;

  TripReviewFailure({
    required this.message,
  });
}

final class TripReviewsLoadedSuccess extends TripReviewState {
  final List<TripReview> reviews;

  TripReviewsLoadedSuccess({
    required this.reviews,
  });
}

final class TripReviewUpsertedSuccess extends TripReviewState {
  final TripReview review;

  TripReviewUpsertedSuccess({
    required this.review,
  });
}

final class TripReviewDeletedSuccess extends TripReviewState {
  final int id;
  TripReviewDeletedSuccess({
    required this.id,
  });
}
