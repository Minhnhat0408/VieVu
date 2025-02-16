import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';

abstract interface class TripLocationRepository {
  Future<Either<Failure, TripLocation>> insertTripLocation({
    required String tripId,
    required int locationId,
  });

  Future<Either<Failure, Unit>> updateTripLocation({
    required int id,
    required bool isStartingPoint,
  });

  Future<Either<Failure, Unit>> deleteTripLocation({
    required String tripId,
    required int locationId,
  });

  Future<Either<Failure, List<TripLocation>>> getTripLocations({
    required String tripId,
  });
}
