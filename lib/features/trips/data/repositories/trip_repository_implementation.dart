import 'dart:io';

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
  Future<Either<Failure, Trip>> getTripDetails({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final trip = await tripRemoteDatasource.getTripDetails(tripId: tripId);
      return right(trip);
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
  Future<Either<Failure, Trip>> updateTrip({
    required String tripId,
    String? description,
    File? cover,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    String? name,
    List<String>? transports,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      String? imageUrl;
      if (cover != null) {
        imageUrl = await tripRemoteDatasource.uploadTripCover(
          file: cover,
          tripId: tripId,
        );
      }

      final res = await tripRemoteDatasource.updateTrip(
        tripId: tripId,
        description: description,
        startDate: startDate,
        name: name,
        endDate: endDate,
        cover: imageUrl,
        updatedAt: DateTime.now().toIso8601String(),
        maxMember: maxMember,
        status: status,
        isPublished: isPublished,
        transports: transports,
      );
      return right(res);
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

  @override
  Future<Either<Failure, List<Trip>>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
    required String type,
  }) async {
    try {
      final trips = await tripRemoteDatasource.getCurrentUserTripsForSave(
        userId: userId,
        status: status,
        isPublished: isPublished,
        id: id,
        type: type,
      );
      return right(trips);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
