import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_member_remote_datasource.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:vievu/features/trips/domain/repositories/trip_member_repository.dart';

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
      await chatRemoteDatasource.updateAvailableChatMember(
          tripId: tripId, userId: userId, available: false);
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
      final res = await tripMemberRemoteDatasource.updateTripMember(
          tripId: tripId, userId: userId, role: role, isBanned: isBanned);

      if (isBanned == true) {
        await chatRemoteDatasource.updateAvailableChatMember(
            tripId: tripId, userId: userId, available: false);
      } else if (isBanned == false) {
        await chatRemoteDatasource.updateAvailableChatMember(
            tripId: tripId, userId: userId, available: true);
      }
      return right(res);
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

  @override
  Future<Either<Failure, List<TripMember>>> getBannedUsers({
    required String tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final bannedUsers =
          await tripMemberRemoteDatasource.getBannedUsers(tripId: tripId);
      return right(bannedUsers);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
