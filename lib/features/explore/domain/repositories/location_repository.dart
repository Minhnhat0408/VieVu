import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/explore/domain/entities/location.dart';
import 'package:latlong2/latlong.dart';

abstract interface class LocationRepository {
  Future<Either<Failure, Location>> getLocation({
    required int locationId,
  });

  Future<Either<Failure, List<Location>>> getHotLocations({
    required int limit,
    required int offset,
  });
  Future<Either<Failure, List<Location>>> getRecentViewedLocations({
    required int limit,
  });

  Future<Either<Failure, Unit>> upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  });

  Future<Either<Failure, GenericLocationInfo>> getLocationGeneralInfo({
    required int locationId,
    required String userId,
    required String locationName,
  });

  Future<Either<Failure, GeoApiLocation>> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, GeoApiLocation>> convertAddressToGeoLocation({
    required String address,
  });

  Future<Either<Failure, LatLng>> convertAddressToLatLng({
    required String address,
  });
}
