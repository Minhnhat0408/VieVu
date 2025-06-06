import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/chat/data/models/message_model.dart';

abstract interface class MessageRemoteDatasource {
  Future<MessageModel> insertMessage({
    required int chatId,
    required String message,
    required int chatMemberId,
    List<Map<String, dynamic>>? metaData,
  });

  Future updateSeenMessage({
    required int chatId,
    required int messageId,
  });
  Future updateMessage({
    required int messageId,
    String? content,
    List<Map<String, dynamic>>? metaData,
  });

  Future<List<MessageModel>> getMessagesInChat({
    required int chatId,
    required int limit,
    required int offset,
  });
  RealtimeChannel listenToMessageUpdateChannel({
    required int chatId,
    // required int chatMemberId,
    required Function(Map<String, dynamic>) callback,
  });
  RealtimeChannel listenToMessagesChannel({
    int? chatId,
    required int chatMemberId,
    required Function(MessageModel?) callback,
  });

  void unSubcribeToMessagesChannel({
    required String channelName,
  });

  Future<MessageReactionModel> insertReaction({
    required int messageId,
    required String reaction,
    required int chatMemberId,
    required int chatId,
  });

  Future removeReaction({
    required int messageId,
    required int chatMemberId,
  });

  RealtimeChannel listenToMessageReactionChannel({
    required int chatId,
    required int chatMemberId,
    required Function({
      MessageReactionModel? messageReaction,
      required int reactionId,
      required String eventType,
    }) callback,
  });

  Future<MessageModel> removeMessage({
    required int messageId,
  });

  Future<List<MessageModel>> getScrollToMessages({
    required int messageId,
    required int lastMessageId,
    required int chatId,
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
    required int chatMemberId,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }


      List<Map<String, dynamic>>? processedMetaData = metaData?.map((item) {
        return item.map((key, value) {
          if (value is DateTime) {
            return MapEntry(key, value.toIso8601String());
          }
          return MapEntry(key, value);
        });
      }).toList();

      final res = await supabaseClient
          .from('messages')
          .insert({
            'chat_id': chatId,
            'chat_member_id': chatMemberId,
            'content': message,
            'meta_data': processedMetaData,
          })

          .select("*, chat_members!messages_chat_member_id_fkey(profiles(*))")

          .single();
      return MessageModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getScrollToMessages({
    required int messageId,
    required int lastMessageId,
    required int chatId,
  }) async {
    try {
      final res = await supabaseClient
          .from('messages')
          .select(
              "*, chat_members!messages_chat_member_id_fkey(profiles(*)), message_reactions(*, chat_members(profiles(*)))")
          .eq('chat_id', chatId)
          .lt('id', lastMessageId)
          .gte('id', messageId)
          .order('created_at', ascending: false);

      return res.map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future updateMessage({
    required int messageId,
    String? content,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      await supabaseClient
          .from('messages')
          .update({
            'content': content,
            'meta_data': metaData,
          })
          .eq('id', messageId)
          .eq('user_id', user.id);
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
          .select(
              "*, chat_members!messages_chat_member_id_fkey(profiles(*)), message_reactions(*, chat_members(profiles(*)))")
          .eq('chat_id', chatId)
          .range(offset, offset + limit)
          .order('created_at', ascending: false);

      return res.map((e) {
        return MessageModel.fromJson(e);
      }).toList();
    } catch (e) {
      log("${e}getMessagesInChat");
      throw ServerException(e.toString());
    }
  }

  @override
  RealtimeChannel listenToMessagesChannel({
    int? chatId,
    required int chatMemberId,
    required Function(MessageModel?) callback,
  }) {
    return supabaseClient
        .channel('chat_insert:$chatId')
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
            if (user == null) {
              throw const ServerException("Không tìm thấy người dùng");
            }
            if (chatId == null) {
              callback(null);
            } else {
              await updateSeenMessage(chatId: chatId, messageId: data['id']);
              if (data['chat_member_id'] == chatMemberId) {
                callback(null);
              } else {
                final user = await supabaseClient
                    .from('chat_members')
                    .select('profiles(*)')
                    .eq('id', data['chat_member_id'])
                    .single();
                data['chat_members'] = {
                  'profiles': user['profiles'],
                };
                final message = MessageModel.fromJson(data);

                callback(message);

                
              }
            }
          },
        )
        .subscribe();
  }

  @override
  RealtimeChannel listenToMessageUpdateChannel({
    required int chatId,
    required Function(Map<String, dynamic>) callback,
  }) {
    return supabaseClient
        .channel('chat_update:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_id',
              value: chatId),
          callback: (payload) async {
            final data = payload.newRecord;
            callback(data);
          },
        )
        .subscribe();
  }

  @override
  RealtimeChannel listenToMessageReactionChannel({
    required int chatId,
    required int chatMemberId,
    required Function({
      MessageReactionModel? messageReaction,
      required int reactionId,
      required String eventType,
    }) callback,
  }) {
    return supabaseClient
        .channel('message_reactions:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'message_reactions',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_id',
              value: chatId),
          callback: (payload) async {
            final event = payload.eventType;
            final user = supabaseClient.auth.currentUser;
            if (user == null) {
              throw const ServerException("Không tìm thấy người dùng");
            }
            if (event == PostgresChangeEvent.insert ||
                event == PostgresChangeEvent.update) {
              final data = payload.newRecord;
              if (data['chat_member_id'] != chatMemberId) {
                final user = await supabaseClient
                    .from('chat_members')
                    .select('profiles(*)')
                    .eq('id', data['chat_member_id'])
                    .single();
                data['chat_members'] = {
                  'profiles': user['profiles'],
                };
                callback(
                  messageReaction: MessageReactionModel.fromJson(data),
                  reactionId: data['id'],
                  eventType: event.name,
                );
              }
            } else {
              final data = payload.oldRecord;

              callback(
                messageReaction: null,
                reactionId: data['id'],
                eventType: event.name,
              );
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

  @override
  Future<MessageReactionModel> insertReaction({
    required int messageId,
    required int chatId,
    required int chatMemberId,
    required String reaction,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      final res = await supabaseClient
          .from('message_reactions')
          .upsert({
            'message_id': messageId,
            // 'user_id': user.id,
            'chat_member_id': chatMemberId,
            'reaction': reaction,
            'chat_id': chatId,
          }, onConflict: 'user_id, message_id')
          .select("*, chat_members(profiles(*))")
          .single();
      return MessageReactionModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future removeReaction({
    required int messageId,
    required int chatMemberId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      await supabaseClient
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('chat_member_id', chatMemberId);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MessageModel> removeMessage({
    required int messageId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      final res = await supabaseClient
          .from('messages')
          .update({
            'content': null,
            'is_travel_related': false,
            'meta_data': [],
          })
          .eq('id', messageId)
          .select("*, chat_members!messages_chat_member_id_fkey(profiles(*))")
          .single();
      // remove any reactions
      await supabaseClient
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId);
      return MessageModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
