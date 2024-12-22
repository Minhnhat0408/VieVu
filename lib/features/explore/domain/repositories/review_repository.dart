import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';

abstract interface class ReviewRepository {
  Future<Either<Failure, List<Review>>> getAttractionReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
  });
}
