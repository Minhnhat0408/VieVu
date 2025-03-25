import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_member_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_member_repository.dart';

class TripMemberRepositoryImpl implements TripMemberRepository {
  final TripMemberRemoteDatasource tripMemberRemoteDatasource;
  final ChatRemoteDatasource chatRemoteDatasource;
  final ConnectionChecker connectionChecker;
  TripMemberRepositoryImpl(
      {required this.chatRemoteDatasource,
      required this.tripMemberRemoteDatasource,
      required this.connectionChecker});

  @override
  Future<Either<Failure, TripMember?>> getMyTripMemberToTrip({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final tripMember = await tripMemberRemoteDatasource.getMyTripMemberToTrip(
          tripId: tripId);
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
      await chatRemoteDatasource.deleteChatMembers(id: tripId, userId: userId);
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
  Future<Either<Failure, Unit>> insertTripMember({
    required String tripId,
    required String userId,
    required String role,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripMemberRemoteDatasource.insertTripMember(
          tripId: tripId, userId: userId, role: role);

      await chatRemoteDatasource.insertChatMembers(
          tripId: tripId, userId: userId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTripMember({
    required String tripId,
    required String userId,
    String? role,
    bool? isBanned,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripMemberRemoteDatasource.updateTripMember(
          tripId: tripId, userId: userId, role: role, isBanned: isBanned);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> rateTripMember({
    required int memberId,
    required int rating,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripMemberRemoteDatasource.rateTripMember(
          memberId: memberId, rating: rating);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> inviteTripMember({
    required String tripId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await tripMemberRemoteDatasource.inviteTripMember(
          tripId: tripId, userId: userId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TripMemberRating>>> getRatedUsers(
      {required String userId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final ratedUsers =
          await tripMemberRemoteDatasource.getRatedUsers(userId: userId);
      return right(ratedUsers);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
