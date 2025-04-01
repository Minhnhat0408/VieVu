import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/trips/data/datasources/saved_service_remote_datasource.dart';
import 'package:vievu/features/trips/domain/entities/saved_services.dart';
import 'package:vievu/features/trips/domain/repositories/saved_service_repository.dart';

class SavedServiceRepositoryImpl implements SavedServiceRepository {
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final ConnectionChecker connectionChecker;

  SavedServiceRepositoryImpl(
      this.savedServiceRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, SavedService>> insertSavedService({
    required String tripId,
    String? externalLink,
    required int linkId,
    DateTime? eventDate,
    required String cover,
    required String name,
    required String locationName,
    List<String>? tagInfoList,
    required double rating,
    required int ratingCount,
    int? hotelStar,
    int? price,
    required int typeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await savedServiceRemoteDatasource.insertSavedService(
        tripId: tripId,
        externalLink: externalLink,
        linkId: linkId,
        cover: cover,
        price: price,
        name: name,
        locationName: locationName,
        tagInfoList: tagInfoList,
        rating: rating,
        eventDate: eventDate,
        ratingCount: ratingCount,
        hotelStar: hotelStar,
        typeId: typeId,
        latitude: latitude,
        longitude: longitude,
      );
      return right(res);
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

  @override
  Future<Either<Failure, List<int>>> getListSavedServiceIds(
      {required String userId, required List<int> serviceIds}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final savedServiceIds =
          await savedServiceRemoteDatasource.getListSavedServiceIds(
        userId: userId,
        serviceIds: serviceIds,
      );
      return right(savedServiceIds);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
