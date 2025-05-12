part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoadedSuccess extends NotificationState {
  final List<Notification> notifications;

  NotificationLoadedSuccess({required this.notifications});
}

final class NotificationError extends NotificationState {
  final String message;
  final int? id;

  NotificationError({
    required this.message,
     this.id,
  });
}

final class NotificationDeleted extends NotificationState {}

final class NotificationMarkedAsRead extends NotificationState {}

final class AllNotificationsMarkedAsRead extends NotificationState {}

final class NotificationSent extends NotificationState {}

final class UnreadNotificationsCount extends NotificationState {
  final int count;

  UnreadNotificationsCount({required this.count});
}

final class TripInvitationAccepted extends NotificationState {}

final class TripInvitationRejected extends NotificationState {}
