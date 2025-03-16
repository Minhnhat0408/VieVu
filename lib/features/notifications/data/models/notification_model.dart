import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/notifications/domain/entities/notification.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_model.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required super.id,
    required super.content,
     super.user,
     super.trip,
    required super.type,
    required super.createdAt,
    required super.isRead,
    super.isAccepted
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      content: json['content'],
      user: json['profiles'] != null
          ? UserModel.fromJson(json['profiles'])
          : null,
      trip: json['trips'] != null ? TripModel.fromJson(json['trips']) : null,
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      isAccepted: json['is_accepted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user': user,
      'trip': trip,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
