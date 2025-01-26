import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';

abstract interface class SavedServiceRepository {
  Future<Either<Failure, Unit>> insertSavedService({
    required String tripId,
    String? externalLink,
    required int linkId,
    required String cover,
    required String name,
    required String locationName,
    List<String>? tagInfoList,
    required double rating,
    required int ratingCount,
    int? hotelStar,
    required int typeId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, Unit>> deleteSavedService(
      {required int linkId, required String tripId});

  Future<Either<Failure, List<SavedService>>> getSavedServices({
    required String tripId,
    int? typeId,
  });
}
