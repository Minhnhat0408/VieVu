import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/review_repository.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewRepository _reviewRepository;
  ReviewsCubit({
    required ReviewRepository reviewRepository,
  })  : _reviewRepository = reviewRepository,
        super(ReviewsInitial());

  Future<void> fetchReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
  }) async {
    emit(ReviewsLoading());
    final result = await _reviewRepository.getAttractionReviews(
      attractionId: attractionId,
      limit: limit,
      pageIndex: pageIndex,
    );
    result.fold(
      (failure) => emit(ReviewsFailure(failure.message)),
      (reviews) => emit(ReviewsLoadedSuccess(reviews)),
    );
  }
}
