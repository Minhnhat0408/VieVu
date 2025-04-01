import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/trips/domain/entities/trip_review.dart';

abstract interface class TripReviewRepository {
  Future<Either<Failure, List<TripReview>>> getTripReviews({
    required String tripId,
    String sortType = 'latest',
  });

  Future<Either<Failure, TripReview>> upsertTripReview({
    required String tripId,
    required int memberId,
    String? review,
    required double rating,
  });

  Future<Either<Failure, Unit>> deleteTripReview({
    required int id,
  });
}
