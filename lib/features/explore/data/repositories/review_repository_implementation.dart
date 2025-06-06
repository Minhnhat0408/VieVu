import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/explore/data/datasources/review_remote_datasource.dart';
import 'package:vievu/features/explore/domain/entities/review.dart';
import 'package:vievu/features/explore/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource reviewRemoteDataSource;
  final ConnectionChecker connectionChecker;
  const ReviewRepositoryImpl(
      this.reviewRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<Review>>> getAttractionReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
    required int commentTagId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final reviews = await reviewRemoteDataSource.getAttractionReviews(
        attractionId: attractionId,
        limit: limit,
        pageIndex: pageIndex,
        commentTagId: commentTagId,
      );

      return right(reviews);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
