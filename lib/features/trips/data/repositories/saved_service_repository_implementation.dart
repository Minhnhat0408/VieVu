import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/saved_service_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/data/models/saved_service_model.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/saved_service_repository.dart';

class SavedServiceRepositoryImpl implements SavedServiceRepository {
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final ConnectionChecker connectionChecker;

  SavedServiceRepositoryImpl(
      this.savedServiceRemoteDatasource, this.connectionChecker);

  @override
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
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await savedServiceRemoteDatasource.insertSavedService(
        tripId: tripId,
        externalLink: externalLink,
        linkId: linkId,
        cover: cover,
        name: name,
        locationName: locationName,
        tagInfoList: tagInfoList,
        rating: rating,
        ratingCount: ratingCount,
        hotelStar: hotelStar,
        typeId: typeId,
        latitude: latitude,
        longitude: longitude,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSavedService({
    required int linkId,
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await savedServiceRemoteDatasource.deleteSavedTrips(
        linkId: linkId,
        tripId: tripId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SavedService>>> getSavedServices({
    required String tripId,
    int? typeId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final savedServices = await savedServiceRemoteDatasource.getSavedServices(
        tripId: tripId,
        typeId: typeId,
      );

      if (savedServices == null) {
        return left(Failure("Không có dữ liệu"));
      }
      return right(savedServices);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
