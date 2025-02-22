import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_itinerary_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_itinerary_repository.dart';

class TripItineraryRepositoryImpl implements TripItineraryRepository {
  final TripItineraryRemoteDatasource tripItineraryRemoteDatasource;
  final ConnectionChecker connectionChecker;

  TripItineraryRepositoryImpl(
      this.tripItineraryRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, TripItinerary>> insertTripItinerary({
    required String tripId,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String title,
    String? note,
    int? serviceId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await tripItineraryRemoteDatasource.insertTripItinerary(
        tripId: tripId,
        time: time,
        latitude: latitude,
        longitude: longitude,
        title: title,
        note: note,
        serviceId: serviceId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripItinerary>> updateTripItinerary({
    required int id,
    String? note,
    DateTime? time,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await tripItineraryRemoteDatasource.updateTripItinerary(
        id: id,
        note: note,
        time: time,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTripItinerary({
    required String tripId,
    required int itineraryId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripItineraryRemoteDatasource.deleteTripItinerary(
        tripId: tripId,
        ItineraryId: itineraryId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TripItinerary>>> getTripItineraries({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await tripItineraryRemoteDatasource.getTripItineraries(
        tripId: tripId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
