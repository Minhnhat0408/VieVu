import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/event_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/event.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource eventRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const EventRepositoryImpl(this.eventRemoteDatasource, this.connectionChecker);
  @override
  Future<Either<Failure, List<Event>>> getHotEvents() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final events = await eventRemoteDatasource.getHotEvents();

      return right(events);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
