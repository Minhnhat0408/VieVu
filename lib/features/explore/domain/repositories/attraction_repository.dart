import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';

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

  Future<Either<Failure, List<Service>>> getServicesNearAttraction({
    required int attractionId,
    int limit = 20,
    int offset = 1,
    required int
        serviceType, // 1 for restaurant, 2 for poi,3 for shop, 4 for hotel
    required String filterType, // 43;true 42;true nearbyDistance nearby10KM
  });

  
}
