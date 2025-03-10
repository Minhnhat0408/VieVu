import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';

abstract interface class TripRepository {
  Future<Either<Failure, List<Trip>>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  });

  Future<Either<Failure, Trip>> insertTrip({
    required String name,
    required String userId,
  });

  Future<Either<Failure, Trip>> getTripDetails({
    required String tripId,
  });

  Future<Either<Failure, Trip>> updateTrip({
    required String tripId,
    String? description,
    File? cover,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  });

  Future<Either<Failure, Unit>> deleteTrip({
    required String tripId,
  });

  Future<Either<Failure, List<Trip>>> getCurrentUserTrips({
    required String userId,
    String? status,
    bool? isPublished,
    required int limit,
    required int offset,
  });

  Future<Either<Failure, List<Trip>>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
  });
}
