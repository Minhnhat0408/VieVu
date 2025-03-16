part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

class GetNotifications extends NotificationEvent {
  final int limit;
  final int offset;
  GetNotifications({
    required this.limit,
    required this.offset,
  });
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  MarkNotificationAsRead({required this.notificationId});
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  DeleteNotification({required this.notificationId});
}

class SendNotification extends NotificationEvent {
  final String content;
  final String? userId;
  final String? tripId;
  final String type;

  SendNotification({
    required this.content,
    this.userId,
    this.tripId,
    required this.type,
  });
}

class GetUnreadNotificationsCount extends NotificationEvent {}

class AcceptTripInvitation extends NotificationEvent {
  final int notificationId;
  final String tripId;
  final String userId;

  AcceptTripInvitation({
    required this.notificationId,
    required this.tripId,
    required this.userId,
  });
}

class RejectTripInvitation extends NotificationEvent {
  final String userId;
  final int notificationId;
  final String tripId;

  RejectTripInvitation({
    required this.userId,
    required this.notificationId,
    required this.tripId,
  });
}
