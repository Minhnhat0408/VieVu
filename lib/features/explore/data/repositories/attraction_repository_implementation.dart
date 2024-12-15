import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  final AttractionRemoteDatasource attractionRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const AttractionRepositoryImpl(
      this.attractionRemoteDatasource, this.connectionChecker);
  @override
  Future<Either<Failure, Attraction>> getAttraction(
      {required int attractionId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final attraction = await attractionRemoteDatasource.getAttraction(
        attractionId: attractionId,
      );

      if (attraction == null) {
        return left(Failure("Không tìm thấy địa điểm"));
      }

      return right(attraction);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getHotAttractions({
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final attractions = await attractionRemoteDatasource.getHotAttractions(
        limit: limit,
        offset: offset,
      );

      return right(attractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getRecentViewedAttractions({
    required int limit,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final attractions =
          await attractionRemoteDatasource.getRecentViewedAttractions(
        limit: limit,
      );

      return right(attractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertRecentViewedAttractions({
    required int attractionId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      await attractionRemoteDatasource.upsertRecentViewedAttractions(
        attractionId: attractionId,
        userId: userId,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getNearbyAttractions({
    required double latitude,
    required double longitude,
    required int limit,
    required int offset,
    required int radius,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final attractions = await attractionRemoteDatasource.getNearbyAttractions(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        offset: offset,
        radius: radius,
      );

      return right(attractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
