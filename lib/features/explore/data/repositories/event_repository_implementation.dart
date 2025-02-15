import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/event_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/event.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource eventRemoteDatasource;
  final LocationRemoteDatasource locationRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const EventRepositoryImpl({
    required this.eventRemoteDatasource,
    required this.locationRemoteDatasource,
    required this.connectionChecker,
  });
  @override
  Future<Either<Failure, List<Event>>> getHotEvents({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final events = await eventRemoteDatasource.getHotEvents(
        userId: userId,
      );

      return right(events);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetails({
    required int eventId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final event = await eventRemoteDatasource.getEventDetails(
        eventId: eventId,
      );

      final add = await locationRemoteDatasource.convertAddressToGeoLocation(
        address: event.venue,
      );

      return right(event.copyWith(
        latitude: add.latitude,
        longitude: add.longitude,
        locationId: add.id,
        locationName: add.cityName,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
