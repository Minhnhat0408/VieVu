import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/explore/domain/entities/event.dart';

abstract interface class EventRepository {
  Future<Either<Failure, List<Event>>> getHotEvents({
    required String userId,
  });

  Future<Either<Failure, Event>> getEventDetails({
    required int eventId,
  });
}
