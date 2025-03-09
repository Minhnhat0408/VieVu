import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_member_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_member_repository.dart';

class TripMemberRepositoryImpl implements TripMemberRepository {
  final TripMemberRemoteDatasource tripMemberRemoteDatasource;
  final ConnectionChecker connectionChecker;
  TripMemberRepositoryImpl(
      this.tripMemberRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, TripMember?>> getMyTripMemberToTrip({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripMember =
          await tripMemberRemoteDatasource.getMyTripMemberToTrip(tripId: tripId);
      return right(tripMember);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTripMember({
    required String tripId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripMemberRemoteDatasource.deleteTripMember(
          tripId: tripId, userId: userId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TripMember>>> getTripMembers({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripMembers =
          await tripMemberRemoteDatasource.getTripMembers(tripId: tripId);
      return right(tripMembers);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripMember>> insertTripMember({
    required String tripId,
    required String userId,
    required String role,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripMember = await tripMemberRemoteDatasource.insertTripMember(
          tripId: tripId, userId: userId, role: role);
      return right(tripMember);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripMember>> updateTripMember({
    required String tripId,
    required String userId,
    String? role,
    bool? isBanned,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripMember = await tripMemberRemoteDatasource.updateTripMember(
          tripId: tripId, userId: userId, role: role, isBanned: isBanned);
      return right(tripMember);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
