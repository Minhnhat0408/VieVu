import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/trips/domain/entities/trip_itinerary.dart';

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

  Future<Either<Failure, TripItinerary>> updateTripItinerary({
    required int id,
    String? note,
    DateTime? time,
    bool? isDone,
  });

  Future<Either<Failure, Unit>> deleteTripItinerary({
    required int itineraryId,
  });

  Future<Either<Failure, List<TripItinerary>>> getTripItineraries({
    required String tripId,
  });
}
