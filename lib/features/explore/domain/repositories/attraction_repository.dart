import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';

abstract interface class AttractionRepository {
  Future<Either<Failure, Attraction>> getAttraction({
    required int attractionId,
  });

  Future<Either<Failure, List<Attraction>>> getHotAttractions({
    required int limit,
    required int offset,
  });

  Future<Either<Failure, List<Attraction>>> getRecentViewedAttractions({
    required int limit,
  });

  Future<Either<Failure, Unit>> upsertRecentViewedAttractions({
    required int attractionId,
    required String userId,
  });

  Future<Either<Failure, List<Attraction>>> getNearbyAttractions({
    required double latitude,
    required double longitude,
    required int limit,
    required int offset,
    required int radius,
  });

  
}
