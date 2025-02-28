import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/chat/data/models/chat_model.dart';
import 'package:http/http.dart' as http;

abstract class ChatRemoteDatasource {
  Future<ChatModel> insertChat({
    String? name,
    String? tripId,
    String? imageUrl,
  });

  Future insertChatMembers({
    required int id,
    required String userId,
  });

  Future deleteChat({
    required int id,
  });

  Future<List<ChatModel>> getChatHeads();

  Future<List<Map<String, dynamic>>> summarizeItineraries({
    required int chatId,
  });

  Future<List<Map<int, UserModel>>> getSeenUser({
    required int chatId,
  });

  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  });

  void unSubcribeToChatMembersChannel({
    required String channelName,
  });
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final SupabaseClient supabaseClient;

  ChatRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<ChatModel> insertChat({
    String? name,
    String? tripId,
    String? imageUrl,
  }) async {
    try {
      final res = await supabaseClient
          .from('chats')
          .insert({
            'name': name,
            'avatar': imageUrl,
            'trip_id': tripId,
          })
          .select("*")
          .single();

      return ChatModel.fromJson(res);
    } catch (e) {
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
    required int id,
    required String userId,
  }) async {
    try {
      await supabaseClient.from('chat_members').insert({
        'chat_id': id,
        'user_id': userId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteChat({
    required int id,
  }) async {
    try {
      final res = await supabaseClient.from('chats').delete().eq('id', id);
    } catch (e) {
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

      log(data.toString());
      return data.map((e) => ChatModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> summarizeItineraries({
    required int chatId,
  }) async {
    try {
      final url =
          Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/summarize');

      final chat = await supabaseClient
          .from('chats')
          .select('trip_id, trips(start_date,end_date)')
          .eq('id', chatId)
          .single();
      final message = await supabaseClient
          .from('messages')
          .select('id,content,meta_data')
          .eq('chat_id', chatId)
          .eq('is_travel_related', true)
          .order('created_at', ascending: true);

      final body = {
        "conversation": message.map((e) => e['content']).toList(),
        "metadata": message
            .where((e) => e['meta_data'] != null)
            .expand((e) => e['meta_data'])
            .toList(),
        "start_date": chat['trips']['start_date'],
        "end_date": chat['trips']['end_date'],
      };

      log(body.toString());

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Specify the content type
        },
        body: jsonEncode(body), // Convert the body to JSON
      );
      final jsonResponse = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(jsonResponse['data']);

      //check if metadata .title contain the  data .title from the response if not add it in the metadata

      return [
        {
          "title": "Itineraries",
          "data": data,
        }
      ];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  }) {
    return supabaseClient
        .channel('chat_members: $chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_members',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_id',
              value: chatId),
          callback: (payload) async {
            log("ehlloo : ${payload.newRecord.toString()}");

            callback();
          },
        )
        .subscribe();
  }

  @override
  void unSubcribeToChatMembersChannel({
    required String channelName,
  }) {
    supabaseClient.channel(channelName).unsubscribe();
  }
}
