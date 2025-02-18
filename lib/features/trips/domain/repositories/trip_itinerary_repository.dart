import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';

abstract interface class TripItineraryRepository {
  Future<Either<Failure, TripItinerary>> insertTripItinerary({
    required String tripId,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String title,
    String? note,
    int? serviceId,
  });

  Future<Either<Failure, Unit>> updateTripItinerary({
    required int id,
    required bool isStartingPoint,
  });

  Future<Either<Failure, Unit>> deleteTripItinerary({
    required String tripId,
    required int itineraryId,
  });

  Future<Either<Failure, List<TripItinerary>>> getTripItineraries({
    required String tripId,
  });
}
