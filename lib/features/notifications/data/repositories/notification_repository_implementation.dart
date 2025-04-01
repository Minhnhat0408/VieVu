import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vievu/features/notifications/domain/entities/notification.dart';
import 'package:vievu/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, Unit>> deleteNotification({
    required int notificationId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.deleteNotification(notificationId: notificationId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      final notifications = await remoteDataSource.getNotifications(
        limit: limit,
        offset: offset,
      );
      return right(notifications);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.markAllNotificationsAsRead();
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead({
    required int notificationId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.markNotificationAsRead(
          notificationId: notificationId);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendNotification({
    required String content,
    String? userId,
    String? tripId,
    required String type,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.sendNotification(
        content: content,
        userId: userId,
        tripId: tripId,
        type: type,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      final res = await remoteDataSource.getUnreadNotificationsCount();
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptTripInvitation({
    required int notificationId,
    required String tripId,
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.acceptTripInvitation(
        notificationId: notificationId,
        tripId: tripId,
        userId: userId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectTripInvitation({
    required String userId,
    required int notificationId,
    required String tripId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure("No internet connection"));
      }
      await remoteDataSource.rejectTripInvitation(
        userId: userId,
        notificationId: notificationId,
        tripId: tripId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
