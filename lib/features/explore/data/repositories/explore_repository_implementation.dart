import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final AttractionRemoteDatasource attractionRemoteDatasource;
  final LocationRemoteDatasource locationRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const ExploreRepositoryImpl(this.attractionRemoteDatasource,
      this.locationRemoteDatasource, this.connectionChecker);
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
  Future<Either<Failure, Location>> getLocation({
    required int locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final location = await locationRemoteDatasource.getLocation(
        locationId: locationId,
      );
      if (location == null) {
        return left(Failure("Không tìm thấy địa điểm"));
      }

      return right(location);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getHotLocations({
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final locations = await locationRemoteDatasource.getHotLocations(
        limit: limit,
        offset: offset,
      );

      return right(locations);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getRecentViewedLocations({
    required int limit,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final locations = await locationRemoteDatasource.getRecentViewedLocations(
        limit: limit,
      );

      return right(locations);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      await locationRemoteDatasource.upsertRecentViewedLocations(
        locationId: locationId,
        userId: userId,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
