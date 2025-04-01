import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/notifications/data/models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int limit,
    required int offset,
  });

  Future<void> markNotificationAsRead({
    required int notificationId,
  });

  Future<void> markAllNotificationsAsRead();

  Future<void> deleteNotification({
    required int notificationId,
  });

  Future<void> sendNotification({
    required String content,
    String? userId,
    String? tripId,
    required String type,
  });

  Future<int> getUnreadNotificationsCount();

  Future<void> acceptTripInvitation({
    required int notificationId,
    required String tripId,
    required String userId,
  });

  Future<void> rejectTripInvitation({
    required String userId,
    required int notificationId,
    required String tripId,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl(
    this.supabaseClient,
  );

  @override
  Future<List<NotificationModel>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không thể lấy thông báo");
      }
      final res = await supabaseClient
          .from('notifications')
          .select('*, profiles!notifications_sender_id_fkey(*), trips(*)')
          .eq('receiver_id', user.id)
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return res.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markNotificationAsRead({
    required int notificationId,
  }) async {
    try {
      await supabaseClient.from('notifications').update({
        'is_read': true,
      }).eq('id', notificationId);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException(
            "Không thể đánh dấu tất cả thông báo đã đọc");
      }
      await supabaseClient.from('notifications').update({
        'is_read': true,
      }).eq('receiver_id', user.id);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteNotification({
    required int notificationId,
  }) async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendNotification({
    required String content,
    String? userId,
    String? tripId,
    required String type,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không thể gửi thông báo");
      }
      await supabaseClient.from('notifications').insert({
        'content': content,
        'sender_id': user.id,
        'receiver_id': userId,
        'trip_id': tripId,
        'type': type,
      });
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không thể lấy thông báo chưa đọc");
      }
      final res = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('receiver_id', user.id)
          .eq('is_read', false)
          .count(CountOption.estimated);
      return res.count;
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  //TODO: implement in repository

  @override
  Future<void> acceptTripInvitation({
    required int notificationId,
    required String tripId,
    required String userId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      await supabaseClient.from('notifications').update({
        'is_read': true,
        'is_accepted': true,
      }).eq('id', notificationId);
      final res = await supabaseClient
          .from('trips')
          .select("max_member, trip_participants(count)")
          .eq('id', tripId)
          .single();
      if (res['trip_participants'][0]['count'] >= res['max_member']) {
        throw const ServerException("Số lượng thành viên đã đủ");
      }
      await supabaseClient.from('trip_participants').insert({
        'trip_id': tripId,
        'user_id': user.id,
        'role': 'member',
      });

      await supabaseClient.from('notifications').insert({
        'content': 'đã chấp nhận lời mời tham gia chuyến đi',
        'sender_id': user.id,
        'receiver_id': userId,
        'trip_id': tripId,
        'type': 'trip_accept',
      });
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectTripInvitation({
    required String userId,
    required int notificationId,
    required String tripId,
  }) async {
    try {
      await supabaseClient.from('notifications').update({
        'is_read': true,
        'is_accepted': false,
      }).eq('id', notificationId);

      await supabaseClient.from('notifications').insert({
        'content': 'đã từ chối lời mời tham gia chuyến đi',
        'sender_id': userId,
        'receiver_id': userId,
        'trip_id': tripId,
        'type': 'trip_reject',
      });
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
