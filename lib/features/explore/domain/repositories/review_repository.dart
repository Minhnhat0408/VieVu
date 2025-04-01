import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/explore/domain/entities/review.dart';

abstract interface class ReviewRepository {
  Future<Either<Failure, List<Review>>> getAttractionReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
    required int commentTagId,
  });
}
