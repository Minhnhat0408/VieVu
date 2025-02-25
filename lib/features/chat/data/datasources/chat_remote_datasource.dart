import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/chat/data/models/chat_model.dart';

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
}
