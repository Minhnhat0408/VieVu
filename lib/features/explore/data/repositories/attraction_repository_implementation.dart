import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/saved_service_remote_datasource.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  final AttractionRemoteDatasource attractionRemoteDatasource;
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const AttractionRepositoryImpl(
      {required this.attractionRemoteDatasource,
      required this.savedServiceRemoteDatasource,
      required this.connectionChecker});
  @override
  Future<Either<Failure, Attraction>> getAttraction(
      {required int attractionId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attraction = await attractionRemoteDatasource.getAttraction(
        attractionId: attractionId,
      );

      if (attraction == null) {
        return left(Failure("Không tìm thấy địa điểm"));
      }

      return right(attraction);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getHotAttractions({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions = await attractionRemoteDatasource.getHotAttractions(
        limit: limit,
        offset: offset,
      );
      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: attractions.map((e) => e.id).toList(),
      );

      final updatedAttractions = attractions
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getRecentViewedAttractions({
    required int limit,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions =
          await attractionRemoteDatasource.getRecentViewedAttractions(
        limit: limit,
      );

      return right(attractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertRecentViewedAttractions({
    required int attractionId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await attractionRemoteDatasource.upsertRecentViewedAttractions(
        attractionId: attractionId,
        userId: userId,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getNearbyAttractions({
    required double latitude,
    required String userId,
    required double longitude,
    required int limit,
    required int offset,
    required int radius,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions = await attractionRemoteDatasource.getNearbyAttractions(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        offset: offset,
        radius: radius,
      );

      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: attractions.map((e) => e.id).toList(),
      );

      final updatedAttractions = attractions
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<Service>>>> getAllServicesNearby({
    required double latitude,
    required double longitude,
    required String userId,
    int limit = 10,
    int offset = 1,
    required String filterType,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions = await attractionRemoteDatasource.getAllServicesNearby(
        limit: limit,
        offset: offset,
        latitude: latitude,
        longitude: longitude,
        filterType: filterType,
      );
      final listIds = attractions.values
          .expand((element) => element.map((e) => e.id))
          .toList();

      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: listIds,
      );
      final updatedAttractions = {
        "restaurants": attractions["restaurants"]!
            .map((element) =>
                element.copyWith(isSaved: linkIds.contains(element.id)))
            .toList(),
        "attractions": attractions["attractions"]!
            .map((element) =>
                element.copyWith(isSaved: linkIds.contains(element.id)))
            .toList(),
        "hotels": attractions["hotels"]!
            .map((element) =>
                element.copyWith(isSaved: linkIds.contains(element.id)))
            .toList(),
      };

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getServicesNearAttraction({
    required int attractionId,
    required String userId,
    int limit = 20,
    int offset = 1,
    required int serviceType,
    required String filterType,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions =
          await attractionRemoteDatasource.getServicesNearAttraction(
        attractionId: attractionId,
        limit: limit,
        offset: offset,
        serviceType: serviceType,
        filterType: filterType,
      );

      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: attractions.map((e) => e.id).toList(),
      );

      final updatedAttractions = attractions
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getRecommendedAttractions({
    required int limit,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions =
          await attractionRemoteDatasource.getRecommendedAttractions(
        limit: limit,
        userId: userId,
      );

      return right(attractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getRelatedAttractions({
    required int attractionId,
    required int limit,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions =
          await attractionRemoteDatasource.getRelatedAttractions(
        attractionId: attractionId,
        limit: limit,
      );

      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: attractions.map((e) => e.id).toList(),
      );

      final updatedAttractions = attractions
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attraction>>> getAttractionsWithFilter({
    String? categoryId1,
    List<String>? categoryId2,
    required int limit,
    required int offset,
    required String userId,
    int? budget,
    int? rating,
    double? lat,
    double? lon,
    int? proximity,
    int? locationId,
    required String sortType,
    required bool topRanked,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final attractions =
          await attractionRemoteDatasource.getAttractionsWithFilter(
        categoryId1: categoryId1,
        categoryId2: categoryId2,
        limit: limit,
        offset: offset,
        lat: lat,
        lon: lon,
        proximity: proximity,
        budget: budget,
        rating: rating,
        locationId: locationId,
        sortType: sortType,
        topRanked: topRanked,
      );
      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: attractions.map((e) => e.id).toList(),
      );

      final updatedAttractions = attractions
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedAttractions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurantsWithFilter({
    int? categoryId1,
    List<int> serviceIds = const [],
    List<int> openTime = const [],
    required int limit,
    required String userId,
    required int offset,
    int? minPrice,
    int? maxPrice,
    double? lat,
    double? lon,
    int? locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final restaurants =
          await attractionRemoteDatasource.getRestaurantsWithFilter(
        categoryId1: categoryId1,
        serviceIds: serviceIds,
        openTime: openTime,
        limit: limit,
        offset: offset,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lat: lat,
        lon: lon,
        locationId: locationId,
      );
      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: restaurants.map((e) => e.id).toList(),
      );

      final updatedRestaurants = restaurants
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedRestaurants);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Hotel>>> getHotelsWithFilter({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int roomQuantity,
    required int adultCount,
    required String userId,
    required int childCount,
    int? star,
    required int limit,
    required int offset,
    int? minPrice,
    int? maxPrice,
    required String locationName,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final hotels = await attractionRemoteDatasource.getHotelsWithFilter(
        checkOutDate: checkOutDate,
        checkInDate: checkInDate,
        roomQuantity: roomQuantity,
        adultCount: adultCount,
        childCount: childCount,
        star: star,
        limit: limit,
        offset: offset,
        minPrice: minPrice,
        maxPrice: maxPrice,
        locationName: locationName,
      );
      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: hotels.map((e) => e.id).toList(),
      );

      final updatedHotels = hotels
          .map((element) =>
              element.copyWith(isSaved: linkIds.contains(element.id)))
          .toList();

      return right(updatedHotels);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
