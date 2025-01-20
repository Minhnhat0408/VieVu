import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';

abstract interface class TripLocationRepository {
  Future<Either<Failure, Unit>> insertTripLocation({
    required String tripId,
    required int locationId,
  });

  Future<Either<Failure, Unit>> updateTripLocation({
    required int id,
    required bool isStartingPoint,
  });

  Future<Either<Failure, Unit>> deleteTripLocation({
    required int id,
  });
}
