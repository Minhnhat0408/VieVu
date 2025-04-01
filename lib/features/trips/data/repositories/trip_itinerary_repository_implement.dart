import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/trips/data/datasources/trip_itinerary_remote_datasource.dart';
import 'package:vievu/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vievu/features/trips/domain/repositories/trip_itinerary_repository.dart';

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
    bool? isDone,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await tripItineraryRemoteDatasource.updateTripItinerary(
        id: id,
        note: note,
        isDone: isDone,
        time: time,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTripItinerary({
    required int itineraryId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripItineraryRemoteDatasource.deleteTripItinerary(
        id: itineraryId,
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
