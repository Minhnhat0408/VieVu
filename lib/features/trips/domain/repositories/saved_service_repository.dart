import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';

abstract interface class SavedServiceRepository {
  Future<Either<Failure, Unit>> insertSavedService({
    required String tripId,
    required SavedService service,
  });

  Future<Either<Failure, Unit>> deleteSavedService({
    required int serviceId,
  });

  Future<Either<Failure, List<SavedService>>> getSavedServices({
    required String tripId,
    int? typeId,
  });
}
