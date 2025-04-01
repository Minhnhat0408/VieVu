import 'package:fpdart/fpdart.dart';
import 'package:latlong2/latlong.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vievu/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vievu/features/explore/data/models/attraction_model.dart';
import 'package:vievu/features/explore/domain/entities/location.dart';
import 'package:vievu/features/explore/domain/repositories/location_repository.dart';
import 'package:vievu/features/trips/data/datasources/saved_service_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDatasource locationRemoteDatasource;
  final AttractionRemoteDatasource attractionRemoteDatasource;
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final ConnectionChecker connectionChecker;
  const LocationRepositoryImpl({
    required this.locationRemoteDatasource,
    required this.attractionRemoteDatasource,
    required this.connectionChecker,
    required this.savedServiceRemoteDatasource,
  });

  @override
  Future<Either<Failure, Location>> getLocation({
    required int locationId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final location = await locationRemoteDatasource.getLocation(
        locationId: locationId,
      );
      if (location == null) {
        return left(Failure("Không tìm thấy địa điểm"));
      }

      return right(location);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getHotLocations({
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final locations = await locationRemoteDatasource.getHotLocations(
        limit: limit,
        offset: offset,
      );

      return right(locations);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getRecentViewedLocations({
    required int limit,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final locations = await locationRemoteDatasource.getRecentViewedLocations(
        limit: limit,
      );

      return right(locations);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await locationRemoteDatasource.upsertRecentViewedLocations(
        locationId: locationId,
        userId: userId,
      );

      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, GenericLocationInfo>> getLocationGeneralInfo({
    required int locationId,
    required String userId,
    required String locationName,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final locationInfo =
          await locationRemoteDatasource.getLocationGeneralInfo(
        locationId: locationId,
      );
      final returnData = GenericLocationInfo(
        attractions: [],
        hotels: [],
        restaurants: [],
        tripbestModule: locationInfo['tripbestModule'],
        comments: locationInfo['comments'],
        locations: locationInfo['locations'],
      );

      final att = await attractionRemoteDatasource.getAttractionsWithFilter(
          locationId: locationId,
          limit: 7,
          offset: 0,
          sortType: "hot_score",
          topRanked: false);

      final ress = await attractionRemoteDatasource.getRestaurantsWithFilter(
        limit: 8,
        offset: 1,
        locationId: locationId,
      );

      final hotel = await attractionRemoteDatasource.getHotelsWithFilter(
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 1)),
        roomQuantity: 1,
        adultCount: 2,
        childCount: 0,
        limit: 8,
        offset: 1,
        locationName: locationName,
      );
      final additionalAtt =
          locationInfo['attractions'] as List<AttractionModel>;
      // add those additional attractions to the list  att if they are not already in the list
      if (att.length < 8) {
        for (var element in additionalAtt) {
          //check by id
          if (att.length >= 8) break;
          if (!att.any((e) => e.id == element.id)) {
            att.add(element);
          }
        }
      }

      final listIds = [
        ...att.map((e) => e.id),
        ...ress.map((e) => e.id),
        ...hotel.map((e) => e.id),
      ];
      final linkIds = await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: listIds,
      );

      returnData.attractions = att.map((e) {
        if (linkIds.contains(e.id)) {
          return e.copyWith(isSaved: true);
        }
        return e;
      }).toList();

      returnData.restaurants = ress.map((e) {
        if (linkIds.contains(e.id)) {
          return e.copyWith(isSaved: true);
        }
        return e;
      }).toList();

      returnData.hotels = hotel.map((e) {
        if (linkIds.contains(e.id)) {
          return e.copyWith(isSaved: true);
        }
        return e;
      }).toList();

      return right(returnData);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, GeoApiLocation>> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final address =
          await locationRemoteDatasource.convertGeoLocationToAddress(
        latitude: latitude,
        longitude: longitude,
      );

      return right(address);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, GeoApiLocation>> convertAddressToGeoLocation({
    required String address,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final geo = await locationRemoteDatasource.convertAddressToGeoLocation(
        address: address,
      );

      return right(geo);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LatLng>> convertAddressToLatLng({
    required String address,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final latLng = await locationRemoteDatasource.convertAddressToLatLng(
        address: address,
      );

      return right(latLng);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
