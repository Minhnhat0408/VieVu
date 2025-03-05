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
    required Function(Map<String, dynamic>) callback,
  });
  RealtimeChannel listenToMessagesChannel({
    int? chatId,
    required Function(MessageModel?) callback,
  });

  void unSubcribeToMessagesChannel({
    required String channelName,
  });

  Future<MessageReactionModel> insertReaction({
    required int messageId,
    required String reaction,
    required int chatId,
  });

  Future removeReaction({
    required int messageId,
  });

  RealtimeChannel listenToMessageReactionChannel({
    required int chatId,
    required Function({
      MessageReactionModel? messageReaction,
      required int reactionId,
      required String eventType,
    }) callback,
  });

  Future<MessageModel> removeMessage({
    required int messageId,
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
      // final url =
      //     Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/ner_message');

      // final body = {
      //   "message": message,
      // };

      // final response = await http.post(
      //   url,
      //   headers: {
      //     "Content-Type": "application/json", // Specify the content type
      //   },
      //   body: jsonEncode(body), // Convert the body to JSON
      // );
      // final jsonResponse = jsonDecode(
      //   utf8.decode(response.bodyBytes),
      // );

      // final List<Map<String, dynamic>> data =
      //     List<Map<String, dynamic>>.from(jsonResponse['data']);

      // //check if metadata .title contain the  data .title from the response if not add it in the metadata
      // final metaDataNew = metaData ?? [];
      // if (data.isNotEmpty) {
      //   for (var element in data) {
      //     final title = element['title'];
      //     if (!metaDataNew.any((element) => element['title'] == title)) {
      //       metaDataNew.add(element);
      //     }
      //   }
      // }
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
            'content': message,
            'user_id': user.id,
            'meta_data': processedMetaData,
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
          .select("*, profiles(*), message_reactions(*, profiles(*))")
          .eq('chat_id', chatId)
          .range(offset, offset + limit)
          .order('created_at', ascending: false);
      // final userSeen = await getSeenUser(chatId: chatId);

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
              if (data['user_id'] != user.id) {
                final user = await supabaseClient
                    .from('profiles')
                    .select('*')
                    .eq('id', data['user_id'])
                    .single();
                data['profiles'] = user;
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
            'user_id': user.id,
            'reaction': reaction,
            'chat_id': chatId,
          }, onConflict: 'user_id, message_id')
          .select("*, profiles(*)")
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
          .eq('user_id', user.id);
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
          .eq('user_id', user.id)
          .select("*, profiles(*)")
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
