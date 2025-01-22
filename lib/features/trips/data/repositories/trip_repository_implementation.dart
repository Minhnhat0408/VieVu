import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDatasource tripRemoteDatasource;
  final ConnectionChecker connectionChecker;

  TripRepositoryImpl(this.tripRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, Unit>> deleteTrip({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripRemoteDatasource.deleteTrip(tripId: tripId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final trips = await tripRemoteDatasource.getTrips(
        limit: limit,
        offset: offset,
        status: status,
        startDate: startDate,
        endDate: endDate,
        transports: transports,
        locationIds: locationIds,
      );
      return right(trips);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Trip>> insertTrip({
    required String name,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final trip =
          await tripRemoteDatasource.insertTrip(name: name, userId: userId);
      return right(trip);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrip({
    required String tripId,
    String? description,
    String? cover,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  }) async {
    try {
      await tripRemoteDatasource.updateTrip(
        tripId: tripId,
        description: description,
        cover: cover,
        startDate: startDate,
        endDate: endDate,
        maxMember: maxMember,
        status: status,
        isPublished: isPublished,
        transports: transports,
      );
      return right(unit);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getCurrentUserTrips({
    required String userId,
    String? status,
    bool? isPublished,
    required int limit,
    required int offset,
  }) async {
    try {
      final trips = await tripRemoteDatasource.getCurrentUserTrips(
        userId: userId,
        status: status,
        isPublished: isPublished,
        limit: limit,
        offset: offset,
      );
      return right(trips);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
