import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/notifications/domain/entities/notification.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getNotifications({
    required int limit,
    required int offset,
  });

  Future<Either<Failure, Unit>> markNotificationAsRead({
    required int notificationId,
  });

  Future<Either<Failure, Unit>> markAllNotificationsAsRead();

  Future<Either<Failure, Unit>> deleteNotification({
    required int notificationId,
  });

  Future<Either<Failure, Unit>> sendNotification({
    required String content,
    String? userId,
    String? tripId,
    required String type,
  });

  Future<Either<Failure, int>> getUnreadNotificationsCount();

  Future<Either<Failure, Unit>> acceptTripInvitation({
    required int notificationId,
    required String tripId,
    required String userId,
  });

  Future<Either<Failure, Unit>> rejectTripInvitation({
    required String userId,
    required int notificationId,
    required String tripId,
  });
}
