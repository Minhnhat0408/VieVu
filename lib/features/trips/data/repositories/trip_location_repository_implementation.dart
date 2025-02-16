import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_location_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_location_repository.dart';

class TripLocationRepositoryImpl implements TripLocationRepository {
  final TripLocationRemoteDatasource tripLocationRemoteDatasource;
  final ConnectionChecker connectionChecker;

  TripLocationRepositoryImpl(
      this.tripLocationRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, TripLocation>> insertTripLocation({
    required String tripId,
    required int locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await tripLocationRemoteDatasource.insertTripLocation(
        tripId: tripId,
        locationId: locationId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTripLocation({
    required int id,
    required bool isStartingPoint,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripLocationRemoteDatasource.updateTripLocation(
        id: id,
        isStartingPoint: isStartingPoint,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTripLocation({
    required String tripId,
    required int locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripLocationRemoteDatasource.deleteTripLocation(
        tripId: tripId,
        locationId: locationId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TripLocation>>> getTripLocations({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripLocations =
          await tripLocationRemoteDatasource.getTripLocations(tripId: tripId);
      return right(tripLocations);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
