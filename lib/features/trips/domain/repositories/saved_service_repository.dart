import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/trips/domain/entities/saved_services.dart';

abstract interface class SavedServiceRepository {
  Future<Either<Failure, SavedService>> insertSavedService({
    required String tripId,
    String? externalLink,
    required int linkId,
    required String cover,
    required String name,
    required String locationName,
    List<String>? tagInfoList,
    DateTime? eventDate,
    required double rating,
    required int ratingCount,
    int? hotelStar,
    int? price,
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

  Future<Either<Failure, List<int>>> getListSavedServiceIds(
      {required String userId, required List<int> serviceIds});
}
