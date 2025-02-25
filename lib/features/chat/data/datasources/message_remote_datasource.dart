import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/chat/data/models/message_model.dart';

abstract interface class MessageRemoteDatasource {
  Future<MessageModel> insertMessage({
    required int chatId,
    required String message,
    List<Map<String, dynamic>>? metaData,
  });

  Future updateSeenMessage({
    required int chatId,
    required int messageId,
  });

  // Future deleteTripItinerary({
  //   required String tripId,
  //   required int ItineraryId,
  // });

  Future<List<MessageModel>> getMessagesInChat({
    required int chatId,
    required int limit,
    required int offset,
  });

  RealtimeChannel listenToMessagesChannel({
    int? chatId,
    required Function(MessageModel?) callback,
  });

  void unSubcribeToMessagesChannel({
    required String channelName,
  });
}

class MessageRemoteDatasourceImpl implements MessageRemoteDatasource {
  final SupabaseClient supabaseClient;

  MessageRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<MessageModel> insertMessage({
    required int chatId,
    required String message,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      final res = await supabaseClient
          .from('messages')
          .insert({
            'chat_id': chatId,
            'content': message,
            'user_id': user.id,
            'meta_data': metaData,
          })
          .select("*, profiles(*)")
          .single();
      return MessageModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future updateSeenMessage({
    required int chatId,
    required int messageId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      await supabaseClient
          .from('chat_members')
          .update({'last_seen_message_id': messageId})
          .eq('chat_id', chatId)
          .eq('user_id', user.id);
      log('update seen message success');
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getMessagesInChat({
    required int chatId,
    required int limit,
    required int offset,
  }) async {
    try {
      final res = await supabaseClient
          .from('messages')
          .select("*, profiles(*)")
          .eq('chat_id', chatId)
          .range(offset, offset + limit)
          .order('created_at', ascending: false);
      return res.map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  RealtimeChannel listenToMessagesChannel({
    int? chatId,
    required Function(MessageModel?) callback,
  }) {
    return supabaseClient
        .channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: chatId != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'chat_id',
                  value: chatId)
              : null,
          callback: (payload) async {
            final data = payload.newRecord;
            final user = supabaseClient.auth.currentUser;
            log('listen to message channel');
            if (user == null) {
              throw const ServerException("Không tìm thấy người dùng");
            }
            if (chatId == null) {
              callback(null);
            } else {
              await updateSeenMessage(chatId: chatId, messageId: data['id']);
              if (data['user_id'] == user.id) {
                callback(null);
              } else {
                final user = await supabaseClient
                    .from('profiles')
                    .select('*')
                    .eq('id', data['user_id'])
                    .single();
                data['profiles'] = user;
                final message = MessageModel.fromJson(data);

                callback(message);
              }
            }
          },
        )
        .subscribe();
  }

  @override
  void unSubcribeToMessagesChannel({
    required String channelName,
  }) {
    supabaseClient.channel(channelName).unsubscribe();
  }
}
