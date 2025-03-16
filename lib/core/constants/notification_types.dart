import 'package:flutter/material.dart';

class NotificationType {
  final String type;
  final String message;
  final Badge badge;

  NotificationType({
    required this.type,
    required this.message,
    required this.badge,
  });

  static NotificationType rating = NotificationType(
    type: 'rating',
    message: 'đã đánh giá bạn',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.star,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.amber,
      padding: EdgeInsets.all(3),
    ),
  );

  static NotificationType tripInvite = NotificationType(
    type: 'trip_invite',
    message: 'đã mời bạn tham gia',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.card_travel,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.all(3),
    ),
  );

  static NotificationType tripInviteAccept = NotificationType(
    type: 'trip_accept',
    message: 'đã đồng ý lời mời tham gia chuyến đi',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.card_travel,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.all(3),
    ),
  );

  static NotificationType tripInviteDecline = NotificationType(
    type: 'trip_reject',
    message: 'đã từ chối lời mời tham gia chuyến đi',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.card_travel,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.all(3),
    ),
  );

  static NotificationType tripBanned = NotificationType(
    type: 'trip_banned',
    message: 'cấm bạn tham gia',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.remove_circle,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.all(3),
    ),
  );

  static NotificationType tripPublic = NotificationType(
    type: 'trip_public',
    message: 'đã công khai chuyến đi mới',
    badge: const Badge(
      label: Icon(
        color: Colors.white,
        Icons.public,
        size: 16,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.all(3),
    ),
  );

  static List<NotificationType> allNotificationType = [
    rating,
    tripInvite,
    tripBanned,
    tripPublic,
    tripInviteAccept,
    tripInviteDecline,
  ];
}
