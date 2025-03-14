import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_review_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_review.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_review_repository.dart';

class TripReviewRepositoryImplementation implements TripReviewRepository {
  final TripReviewRemoteDataSource tripReviewRemoteDataSource;
  final ConnectionChecker connectionChecker;
  TripReviewRepositoryImplementation(
      this.tripReviewRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<TripReview>>> getTripReviews({
    required String tripId,
    String sortType = 'latest',
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripReviews = await tripReviewRemoteDataSource.getTripReviews(
          tripId: tripId, sortType: sortType);
      return right(tripReviews);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripReview>> upsertTripReview({
    required String tripId,
    String? review,
    required int memberId,
    required double rating,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripReview = await tripReviewRemoteDataSource.upsertTripReview(
          tripId: tripId, review: review, rating: rating,
          memberId: memberId);
      return right(tripReview);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTripReview({
    required int id,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripReviewRemoteDataSource.deleteTripReview(id: id);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
