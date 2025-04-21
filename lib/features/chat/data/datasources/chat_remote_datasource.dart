import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/auth/data/models/user_model.dart';
import 'package:vievu/features/chat/data/models/chat_model.dart';
import 'package:http/http.dart' as http;

abstract class ChatRemoteDatasource {
  Future<ChatModel> insertChat({
    String? name,
    String? userId,
    String? tripId,
    String? imageUrl,
  });

  Future insertChatMembers({
    String? tripId,
    int? chatId,
    required String userId,
  });

  Future deleteChat({
    required int id,
  });

  Future deleteChatMembers({
    required String id,
    required String userId,
  });

  Future<ChatModel?> getSingleChat({
    String? userId,
    String? tripId,
  });

  Future<List<ChatModel>> getChatHeads();

  Future<ChatSummarizeModel> summarizeItineraries({
    required int chatId,
  });

  Future<List<Map<int, UserModel>>> getSeenUser({
    required int chatId,
  });

  Future<ChatSummarizeModel?> getCurrentChatSummary({
    required int chatId,
  });

  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  });

  RealtimeChannel listenToChatSummariesChannel({
    required int chatId,
    required Function(ChatSummarizeModel) callback,
  });

  void unSubcribeToChannel({
    required String channelName,
  });

  Future<ChatSummarizeModel> updateSummarize({
    required bool isConverted,
    List<Map<String, dynamic>>? metaData,
    required int chatId,
  });
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final SupabaseClient supabaseClient;

  ChatRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<ChatModel?> getSingleChat({
    String? userId,
    String? tripId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      var res = [];
      if (userId != null) {
        res = await supabaseClient.rpc(
          'get_single_dm_chat_head',
          params: {'user_id_param': user.id, 'receiver_id_param': userId},
        );
      }
      if (tripId != null) {
        res = await supabaseClient.rpc(
          'get_single_trip_chat_head',
          params: {'user_id_param': user.id, 'trip_id_param': tripId},
        );
      }
      log(res.toString());

      if (res.isEmpty) {
        return null;
      }

      return ChatModel.fromJson(res.first);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteChatMembers({
    required String id,
    required String userId,
  }) async {
    try {
      final res = await supabaseClient
          .from('chats')
          .select('id')
          .eq('trip_id', id)
          .maybeSingle();

      if (res == null) {
        return;
      }

      await supabaseClient
          .from('chat_members')
          .delete()
          .eq('chat_id', res['id'])
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatModel> insertChat({
    String? name,
    String? tripId,
    String? userId,
    String? imageUrl,
  }) async {
    try {
      log(userId.toString());
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      if (tripId != null) {
        final res = await supabaseClient
            .from('chats')
            .insert({
              'name': name,
              'avatar': imageUrl,
              'trip_id': tripId,
            })
            .select("id")
            .single();
        final chatId = res['id'];
        await insertChatMembers(chatId: chatId, userId: user.id);
        final chat = await getSingleChat(userId: userId, tripId: tripId);
        return chat!;
      }

      final res =
          await supabaseClient.from('chats').insert({}).select("id").single();
      final chatId = res['id'];
      // insert chat members
      await insertChatMembers(chatId: chatId, userId: user.id);
      await insertChatMembers(chatId: chatId, userId: userId!);

      final chat = await getSingleChat(userId: userId, tripId: tripId);

      return chat!;
    } catch (e) {
      if (e is PostgrestException) {
        if (e.code == '23505') {
          throw "Chat already exists";
        }
        throw ServerException(e.message);
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatSummarizeModel?> getCurrentChatSummary({
    required int chatId,
  }) async {
    try {
      final res = await supabaseClient
          .from('chat_summaries')
          .select('*, chats(trip_id)')
          .eq('chat_id', chatId)
          .maybeSingle();
      if (res == null) {
        return null;
      }

      return ChatSummarizeModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<int, UserModel>>> getSeenUser({
    required int chatId,
  }) async {
    try {
      final res = await supabaseClient
          .from('chat_members')
          .select('*, profiles(*)')
          .eq('chat_id', chatId);

      return res.where((e) => e['last_seen_message_id'] != null).map((e) {
        final user = UserModel.fromJson(e['profiles']);
        final int id = e['last_seen_message_id'];

        return {id: user};
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future insertChatMembers({
    String? tripId,
    int? chatId,
    required String userId,
  }) async {
    try {
      if (tripId == null && chatId == null) {
        throw ServerException("tripId or chatId must be provided");
      }
      if (tripId != null) {
        final res = await supabaseClient
            .from('chats')
            .select('id')
            .eq('trip_id', tripId)
            .single();

        await supabaseClient.from('chat_members').insert({
          'chat_id': res['id'],
          'user_id': userId,
        });
      } else {
        await supabaseClient.from('chat_members').insert({
          'chat_id': chatId,
          'user_id': userId,
        });
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteChat({
    required int id,
  }) async {
    try {} catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ChatModel>> getChatHeads() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      final res = await supabaseClient
          .rpc('get_chat_heads', params: {'user_id_param': user.id}).order(
        'last_message_time',
        ascending: false,
      );

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(res);

      return data.map((e) => ChatModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatSummarizeModel> updateSummarize({
    required bool isConverted,
    required int chatId,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      List<Map<String, dynamic>>? processedMetaData = metaData?.map((item) {
        return item.map((key, value) {
          if (value is DateTime) {
            return MapEntry(key, value.toIso8601String());
          }
          return MapEntry(key, value);
        });
      }).toList();

      final updateObject = processedMetaData != null
          ? {
              'is_converted': isConverted,
              'summary': processedMetaData,
            }
          : {
              'is_converted': isConverted,
            };
      final res = await supabaseClient
          .from('chat_summaries')
          .update(
            updateObject,
          )
          .eq('chat_id', chatId)
          .select("*, chats(trip_id)")
          .single();

      return ChatSummarizeModel.fromJson(res);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatSummarizeModel> summarizeItineraries({
    required int chatId,
  }) async {
    try {

           final user = supabaseClient.auth.currentUser;
      final session = supabaseClient.auth.currentSession;
      if (session == null || user == null) {
        throw const ServerException('Không thể xác thực người dùng');
      }
      final token = session.accessToken;

      final url =
          Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/summarize');

      final chat = await supabaseClient
          .from('chats')
          .select('trip_id, trips(start_date,end_date), chat_summaries(*)')
          .eq('id', chatId)
          .single();
      log(chat.toString());
      final lastSummarizedMessageId = chat['chat_summaries'] != null
          ? chat['chat_summaries']['last_message_id']
          : 0;
      final message = await supabaseClient
          .from('messages')
          .select('id,content,meta_data, message_reactions(reaction)')
          .eq('chat_id', chatId)
          .eq('is_travel_related', true)
          .gt('id', lastSummarizedMessageId)
          .order('created_at', ascending: true);
      if (message.isEmpty) {
        throw const ServerException("Không có tin nhắn mới để tóm tắt");
      }
      final body = {
        "conversation": message.map((e) {
          final reactions = (e['message_reactions'] as List).map((react) {
            return react['reaction'];
          }).toList();
          // check if 👍 have more than 👎 or not
          final isPositive =
              reactions.contains('👎') || reactions.contains('👍')
                  ? reactions.where((e) => e == '👍').length >
                          reactions.where((e) => e == '👎').length
                      ? '|Yes|'
                      : '|No|'
                  : '';

          return e['content'] + isPositive;
        }).toList(),
        "metadata": message
            .where((e) => e['meta_data'] != null)
            .expand((e) => e['meta_data'].map((meta) => {
                  ...meta, // Spread existing metadata
                  'message_id': e['id'] // Add 'message_id' from parent
                }))
            .toList(),
        "start_date": chat['trips']['start_date'],
        "end_date": chat['trips']['end_date'],
      };

      if (chat['chat_summaries'] != null) {
        body['previous_summary'] = chat['chat_summaries']['summary'];
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization" : "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final jsonResponse = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(jsonResponse['data']);

      final res = await supabaseClient
          .from('chat_summaries')
          .upsert({
            'chat_id': chatId,
            'summary': data,
            'readings': jsonResponse['reading'],
            'updated_at': DateTime.now().toIso8601String(),
            'last_message_id': message.last['id'],
            'is_converted': false,
          }, onConflict: 'chat_id')
          .select("*")
          .single();

      res['trip_id'] = chat['trip_id'];
      return ChatSummarizeModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  }) {
    return supabaseClient
        .channel('chat_members:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_members',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_id',
              value: chatId),
          callback: (payload) async {
            callback();
          },
        )
        .subscribe();
  }

  @override
  RealtimeChannel listenToChatSummariesChannel({
    required int chatId,
    required Function(ChatSummarizeModel) callback,
  }) {
    return supabaseClient
        .channel('chat_summaries:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_summaries',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_id',
              value: chatId),
          callback: (payload) async {
            final event = payload.eventType;

            if (event == PostgresChangeEvent.insert ||
                event == PostgresChangeEvent.update) {
              final data = payload.newRecord;

              callback(ChatSummarizeModel.fromJson(data));
            }
          },
        )
        .subscribe();
  }

  @override
  void unSubcribeToChannel({
    required String channelName,
  }) {
    supabaseClient.channel(channelName).unsubscribe();
  }
}
