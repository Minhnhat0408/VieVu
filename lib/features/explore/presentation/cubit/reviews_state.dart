part of 'reviews_cubit.dart';

@immutable
sealed class ReviewsState {}

final class ReviewsInitial extends ReviewsState {}

final class ReviewsLoading extends ReviewsState {}

final class ReviewsLoadedSuccess extends ReviewsState {
  final List<Review> reviews;
  ReviewsLoadedSuccess(this.reviews);
}

final class ReviewsFailure extends ReviewsState {
  final String message;
  ReviewsFailure(this.message);
}