import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_review.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_review_repository.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';

part 'trip_review_event.dart';
part 'trip_review_state.dart';

class TripReviewBloc extends Bloc<TripReviewEvent, TripReviewState> {
  final TripReviewRepository _tripReviewRepository;

  TripReviewBloc({
    required TripReviewRepository tripReviewRepository,
  })  : _tripReviewRepository = tripReviewRepository,
        super(TripReviewInitial()) {
    on<TripReviewEvent>((event, emit) {});
    on<GetTripReviews>(_onGetTripsReviews);
    on<UpsertTripReview>(_onUpsertTripReview);
    on<DeleteTripReview>(_onDeleteTripReview);
  }

  void _onGetTripsReviews(
    GetTripReviews event,
    Emitter<TripReviewState> emit,
  ) async {
    emit(TripReviewLoading());
    final res = await _tripReviewRepository.getTripReviews(
      tripId: event.tripId,
      sortType: event.sortType,
    );
    res.fold(
      (l) => emit(TripReviewFailure(message: l.message)),
      (r) => emit(TripReviewsLoadedSuccess(reviews: r)),
    );
  }

  void _onUpsertTripReview(
    UpsertTripReview event,
    Emitter<TripReviewState> emit,
  ) async {
    emit(TripReviewActionLoading());
    final res = await _tripReviewRepository.upsertTripReview(
      tripId: event.tripId,
      review: event.review,
      memberId: event.memberId,
      rating: event.rating,
    );
    res.fold(
      (l) => emit(TripReviewFailure(message: l.message)),
      (r) => emit(TripReviewUpsertedSuccess(review: r)),
    );
  }

  void _onDeleteTripReview(
    DeleteTripReview event,
    Emitter<TripReviewState> emit,
  ) async {
    emit(TripReviewActionLoading());
    final res = await _tripReviewRepository.deleteTripReview(id: event.id);
    res.fold(
      (l) => emit(TripReviewFailure(message: l.message)),
      (r) => emit(
        TripReviewDeletedSuccess(
          id: event.id,
        ),
      ),
    );
  }
}
