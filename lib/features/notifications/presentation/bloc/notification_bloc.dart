// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/notifications/domain/entities/notification.dart';
import 'package:vievu/features/notifications/domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<NotificationEvent>((event, emit) {});
    on<GetNotifications>(_onGetNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<SendNotification>(_onSendNotification);
    on<GetUnreadNotificationsCount>(_onGetUnreadNotificationsCount);
    on<AcceptTripInvitation>(_onAcceptTripInvitation);
    on<RejectTripInvitation>(_onRejectTripInvitation);
  }

  void _onGetNotifications(
    GetNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.getNotifications(
      limit: event.limit,
      offset: event.offset,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(NotificationLoadedSuccess(notifications: r)),
    );
  }

  void _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.markNotificationAsRead(
      notificationId: event.notificationId,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(NotificationMarkedAsRead()),
    );
  }

  void _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.markAllNotificationsAsRead();
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(AllNotificationsMarkedAsRead()),
    );
  }

  void _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.deleteNotification(
      notificationId: event.notificationId,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(NotificationDeleted()),
    );
  }

  void _onSendNotification(
    SendNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.sendNotification(
      content: event.content,
      userId: event.userId,
      tripId: event.tripId,
      type: event.type,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(NotificationSent()),
    );
  }

  void _onGetUnreadNotificationsCount(
    GetUnreadNotificationsCount event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.getUnreadNotificationsCount();
    res.fold(
      (l) => emit(NotificationError(message: l.message)),
      (r) => emit(UnreadNotificationsCount(count: r)),
    );
  }

  void _onAcceptTripInvitation(
    AcceptTripInvitation event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.acceptTripInvitation(
      notificationId: event.notificationId,
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message, id: event.notificationId)),
      (r) => emit(TripInvitationAccepted()),
    );
  }

  void _onRejectTripInvitation(
    RejectTripInvitation event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final res = await _notificationRepository.rejectTripInvitation(
      notificationId: event.notificationId,
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(NotificationError(message: l.message, id: event.notificationId)),
      (r) => emit(TripInvitationRejected()),
    );
  }
}
