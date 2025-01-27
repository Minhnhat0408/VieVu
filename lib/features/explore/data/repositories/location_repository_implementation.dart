import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDatasource locationRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const LocationRepositoryImpl(
      this.locationRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, Location>> getLocation({
    required int locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
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
        return left(Failure("Không có kết nối mạng"));
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
        return left(Failure("Không có kết nối mạng"));
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
        return left(Failure("Không có kết nối mạng"));
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

  @override
  Future<Either<Failure, GenericLocationInfo>> getLocationGeneralInfo({
    required int locationId,
    required String userId,
    required String locationName,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final location = await locationRemoteDatasource.getLocationGeneralInfo(
        locationId: locationId,
        userId: userId,
        locationName: locationName,
      );

      return right(location);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, GeoApiLocation>> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final address =
          await locationRemoteDatasource.convertGeoLocationToAddress(
        latitude: latitude,
        longitude: longitude,
      );

      return right(address);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
