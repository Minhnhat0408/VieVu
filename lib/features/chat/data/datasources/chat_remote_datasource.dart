import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/constants/prompts.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/auth/data/models/user_model.dart';
import 'package:vievu/features/chat/data/models/chat_model.dart';
import 'package:http/http.dart' as http;

abstract class ChatRemoteDatasource {
  Future<ChatModel> insertChat({
    // String? name,
    String? userId,
    String? tripId,
    // String? imageUrl,
  });

  Future insertChatMembers({
    String? tripId,
    int? chatId,
    required String userId,
  });

  Future updateAvailableChatMember({
    required String tripId,
    required String userId,
    required bool available,
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
      // log(res.toString());

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
    // String? name,
    String? tripId,
    String? userId,
    // String? imageUrl,
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
              // 'name': name,
              // 'avatar': imageUrl,
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

  Future<String?> _callGeminiApiWithSDK({
    required String modelName,
    required String promptText,
    required String systemInstruction,
  }) async {
  

    try {
      // Khởi tạo model với API Key và system instruction
      log(dotenv.env['GEMINI_API_KEY']!);
      final model = genai.GenerativeModel(
        model: modelName,
        apiKey: dotenv.env['GEMINI_API_KEY']!,
        systemInstruction: genai.Content.system(systemInstruction), 
    
      );

      // log("Calling Gemini SDK: $modelName with prompt (first 100 chars): ${promptText.substring(0, math.min(100, promptText.length))}");

      final content = [
        //  genai.Content.system(systemInstruction), // Đặt system instruction ở đây
         genai.Content.text(promptText)
      ];
  

      final response = await model.generateContent(content);

      log("Gemini SDK response: ${response.text}");

      if (response.text != null) {
        return response.text!.trim();
      } else if (response.promptFeedback?.blockReason != null) {
        log("Gemini SDK call blocked: ${response.promptFeedback!.blockReason}");
        return null;
      }
      log("Gemini SDK response format unexpected or no text.");
      return null;

    } catch (e, s) {
      log("Exception calling Gemini SDK: $e", stackTrace: s);
      if (e is  genai.GenerativeAIException) { // Bắt lỗi cụ thể từ SDK nếu có
        log("GenerativeAIException: ${e.message}");
        throw ServerException("Lỗi từ Gemini SDK: ${e.message}");
      }
      throw ServerException("Lỗi khi gọi Gemini SDK: ${e.toString()}");
    }
  }

  @override
  Future<ChatSummarizeModel> summarizeItineraries({
    required int chatId,
  }) async {
    try {
      // Lấy thông tin chat, trip dates, previous summary và messages từ Supabase (logic này vẫn giữ)
      final chat = await supabaseClient
          .from('chats')
          .select('trip_id, trips(start_date,end_date), chat_summaries(*)')
          .eq('id', chatId)
          .single();
      log('Chat data from Supabase for summarization: ${chat.toString()}');

      if (chat['trips'] == null) {
        throw const ServerException(
            'Thông tin chuyến đi không tồn tại cho cuộc trò chuyện này.');
      }
      final String? startDate = chat['trips']['start_date'];
      final String? endDate = chat['trips']['end_date'];

      if (startDate == null || endDate == null) {
        throw const ServerException(
            'Ngày bắt đầu hoặc ngày kết thúc của chuyến đi không được xác định. Vui lòng cập nhật thông tin chuyến đi.');
      }

      final previousSummaryData = chat['chat_summaries'];
      final lastSummarizedMessageId = previousSummaryData != null &&
              previousSummaryData['last_message_id'] != null
          ? previousSummaryData['last_message_id']
          : 0;

      final messagesToSummarize = await supabaseClient
          .from('messages')
          .select('id,content,meta_data, message_reactions(reaction)')
          .eq('chat_id', chatId)
          .eq('is_travel_related', true)
          .gt('id', lastSummarizedMessageId)
          .order('created_at', ascending: true);

      if (messagesToSummarize.isEmpty) {
         if (previousSummaryData != null && previousSummaryData['summary'] != null) {
             log("No new messages to summarize, returning existing summary if valid.");
             if (previousSummaryData['chat_id'] == null) previousSummaryData['chat_id'] = chatId;
             if (previousSummaryData['trip_id'] == null) previousSummaryData['trip_id'] = chat['trip_id'];
             if (previousSummaryData['summary'] is! List ||
                (previousSummaryData['summary'] as List).any((item) => item is! Map<String,dynamic>)) {
                  log("Previous summary is not in the expected format List<Map<String,dynamic>>. Fetching fresh summary.");
                  if (messagesToSummarize.isEmpty) {
                     throw const ServerException("Không có tin nhắn mới và tóm tắt cũ không hợp lệ.");
                  }
             } else {
                return ChatSummarizeModel.fromJson(previousSummaryData);
             }
           }
        throw const ServerException("Không có tin nhắn mới để tóm tắt");
      }

      // Chuẩn bị prompt cho Gemini
      final List<String> conversationPayload = messagesToSummarize.map((e) {
        final List<dynamic> rawReactions =
            (e['message_reactions'] is List<dynamic>)
                ? (e['message_reactions'] as List<dynamic>)
                : <dynamic>[];
        final reactions = rawReactions
            .map((react) => (react is Map<String, dynamic> && react.containsKey('reaction')) ? react['reaction'] : null)
            .where((reactionValue) => reactionValue != null)
            .toList();
        final isPositive = reactions.contains('👎') || reactions.contains('👍')
            ? (reactions.where((r) => r == '👍').length > reactions.where((r) => r == '👎').length ? '|Yes|' : '|No|')
            : '';
        return (e['content'] as String? ?? '') + isPositive;
      }).toList();

      final List<Map<String, dynamic>> metadataPayload = messagesToSummarize
          .where((e) => e['meta_data'] != null && e['meta_data'] is List<dynamic>)
          .expand((e) {
            final List<dynamic> metaDataList = e['meta_data'] as List<dynamic>;
            return metaDataList.map((meta) {
              if (meta is Map<String, dynamic>) {
                return {...meta, 'message_id': e['id']};
              }
              return null;
            }).where((metaItem) => metaItem != null).cast<Map<String, dynamic>>();
          }).toList();

      // 1. Summarize Conversation
      String formattedMessagesForSummary =
          "Conversation:\n${conversationPayload.join('\n')}\nTravel dates: from $startDate to $endDate.\nMetadata: ${jsonEncode(metadataPayload)}.";
      if (previousSummaryData != null && previousSummaryData['summary'] != null && previousSummaryData['summary'] is List) {
        formattedMessagesForSummary += "\nPrevious Summary: ${jsonEncode(previousSummaryData['summary'])}.";
      }

      String? summaryTextFromGemini = await _callGeminiApiWithSDK(
        modelName: 'gemini-2.0-flash',
        promptText: formattedMessagesForSummary,
        systemInstruction: summarizeInstruction,
      );

      List<Map<String, dynamic>> summaryJson = [];
      if (summaryTextFromGemini != null) {
        String processedText = summaryTextFromGemini;
        if (processedText.startsWith("```json")) {
          processedText = processedText.substring(7, processedText.length - 3).trim();
        } else if (processedText.startsWith("```")) {
          processedText = processedText.substring(3, processedText.length - 3).trim();
        }
        try {
          final decoded = jsonDecode(processedText);
          if (decoded is List) {
            summaryJson = decoded.whereType<Map<String, dynamic>>().toList();
          } else {
            log("Parsed summary JSON is not a List: $decoded");
          }
        } catch (e) {
          log("Failed to parse summary JSON from Gemini (SDK): $e, Raw text: $processedText");
        }
      } else {
        log("Summarization with Gemini (SDK) returned no text.");
      }

      // 2. Summarize to Reading
      final String textForReading = summaryJson.isNotEmpty ? jsonEncode(summaryJson) : (summaryTextFromGemini ?? "No summary available.");
      String? readingTextFromGemini = await _callGeminiApiWithSDK(
        modelName: 'gemini-2.0-flash',
        promptText: textForReading,
        systemInstruction: readingInstruction, 
      );

      if (readingTextFromGemini != null) {
        if (readingTextFromGemini.startsWith("```json")) { // Mặc dù reading thường là text, đề phòng
            readingTextFromGemini = readingTextFromGemini.substring(7, readingTextFromGemini.length - 3).trim();
        } else if (readingTextFromGemini.startsWith("```")) {
            readingTextFromGemini = readingTextFromGemini.substring(3, readingTextFromGemini.length - 3).trim();
        }
      } else {
        log("Reading generation with Gemini (SDK) returned no text.");
        readingTextFromGemini = "Could not generate reading text."; // Default fallback
      }

      // Upsert kết quả vào bảng chat_summaries
      final upsertResult = await supabaseClient
          .from('chat_summaries')
          .upsert({
            'chat_id': chatId,
            'summary': summaryJson, // summary từ Gemini
            'readings': readingTextFromGemini, // reading từ Gemini
            'updated_at': DateTime.now().toIso8601String(),
            'last_message_id': messagesToSummarize.last['id'],
            'is_converted': false,
          }, onConflict: 'chat_id')
          .select("*") // Lấy lại tất cả các trường
          .single();

      upsertResult['trip_id'] = chat['trip_id'];

      return ChatSummarizeModel.fromJson(upsertResult);

    } catch (e, s) {
      log('Error in summarizeItineraries (Flutter client-side Gemini SDK): ${e.toString()}', stackTrace: s);
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
          'Đã xảy ra lỗi khi tóm tắt lịch trình (Flutter client-side Gemini SDK): ${e.toString()}');
    }
  }

  // @override
  // Future<ChatSummarizeModel> summarizeItineraries({
  //   required int chatId,
  // }) async {
  //   try {
  //     final user = supabaseClient.auth.currentUser;
  //     final session = supabaseClient.auth.currentSession;
  //     if (session == null || user == null) {
  //       throw const ServerException('Không thể xác thực người dùng');
  //     }
  //     final token = session.accessToken;

  //     final url =
  //         Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/summarize');

  //     final chat = await supabaseClient
  //         .from('chats')
  //         .select('trip_id, trips(start_date,end_date), chat_summaries(*)')
  //         .eq('id', chatId)
  //         .single();
  //     log('Chat data from Supabase: ${chat.toString()}');

  //     // Check if trips data is available and if start_date or end_date is null
  //     if (chat['trips'] == null) {
  //       throw const ServerException(
  //           'Thông tin chuyến đi không tồn tại cho cuộc trò chuyện này.');
  //     }
  //     final String? startDate = chat['trips']['start_date'];
  //     final String? endDate = chat['trips']['end_date'];

  //     if (startDate == null || endDate == null) {
  //       throw const ServerException(
  //           'Ngày bắt đầu hoặc ngày kết thúc của chuyến đi không được xác định. Vui lòng cập nhật thông tin chuyến đi.');
  //     }

  //     final lastSummarizedMessageId = chat['chat_summaries'] != null &&
  //             chat['chat_summaries']['last_message_id'] != null
  //         ? chat['chat_summaries']['last_message_id']
  //         : 0;

  //     final message = await supabaseClient
  //         .from('messages')
  //         .select('id,content,meta_data, message_reactions(reaction)')
  //         .eq('chat_id', chatId)
  //         .eq('is_travel_related', true)
  //         .gt('id', lastSummarizedMessageId)
  //         .order('created_at', ascending: true);

  //     if (message.isEmpty) {
  //       throw const ServerException("Không có tin nhắn mới để tóm tắt");
  //     }

  //     final body = {
  //       "conversation": message.map((e) {
  //         final List<dynamic> rawReactions =
  //             (e['message_reactions'] is List<dynamic>)
  //                 ? (e['message_reactions'] as List<dynamic>)
  //                 : <dynamic>[];

  //         final reactions = rawReactions
  //             .map((react) {
  //               if (react is Map<String, dynamic> &&
  //                   react.containsKey('reaction')) {
  //                 return react['reaction'];
  //               }
  //               return null;
  //             })
  //             .where((reactionValue) => reactionValue != null)
  //             .toList();

  //         final isPositive =
  //             reactions.contains('👎') || reactions.contains('👍')
  //                 ? reactions.where((r) => r == '👍').length >
  //                         reactions.where((r) => r == '👎').length
  //                     ? '|Yes|'
  //                     : '|No|'
  //                 : '';

  //         return (e['content'] as String? ?? '') + isPositive;
  //       }).toList(),
  //       "metadata": message
  //           .where((e) =>
  //               e['meta_data'] != null && e['meta_data'] is List<dynamic>)
  //           .expand((e) {
  //         final List<dynamic> metaDataList = e['meta_data'] as List<dynamic>;
  //         return metaDataList.map((meta) {
  //           if (meta is Map<String, dynamic>) {
  //             return {...meta, 'message_id': e['id']};
  //           }
  //           return null;
  //         }).where((metaItem) => metaItem != null);
  //       }).toList(),
  //       "start_date": startDate, // Use validated startDate
  //       "end_date": endDate, // Use validated endDate
  //     };

  //     if (chat['chat_summaries'] != null &&
  //         chat['chat_summaries']['summary'] != null) {
  //       body['previous_summary'] = chat['chat_summaries']['summary'];
  //     }

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode != 200) {
  //       throw ServerException(
  //           'Lỗi từ API tóm tắt: ${response.statusCode} - ${response.body}');
  //     }

  //     final jsonResponse = jsonDecode(
  //       utf8.decode(response.bodyBytes),
  //     );

  //     final List<Map<String, dynamic>> data =
  //         List<Map<String, dynamic>>.from(jsonResponse['data']);

  //     final res = await supabaseClient
  //         .from('chat_summaries')
  //         .upsert({
  //           'chat_id': chatId,
  //           'summary': data,
  //           'readings': jsonResponse['reading'],
  //           'updated_at': DateTime.now().toIso8601String(),
  //           'last_message_id': message.last['id'],
  //           'is_converted': false,
  //         }, onConflict: 'chat_id')
  //         .select("*")
  //         .single();

  //     res['trip_id'] = chat['trip_id'];
  //     return ChatSummarizeModel.fromJson(res);
  //   } catch (e) {
  //     log('Error in summarizeItineraries: ${e.toString()}');
  //     if (e is ServerException) {
  //       rethrow; // Re-throw ServerException directly
  //     }
  //     throw ServerException(
  //         'Đã xảy ra lỗi khi tóm tắt lịch trình: ${e.toString()}');
  //   }
  // }

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

  @override
  Future updateAvailableChatMember({
    required String tripId,
    required String userId,
    required bool available,
  }) async {
    try {
      final res = await supabaseClient
          .from('chat_members')
          .select('*, chats!inner(trip_id)')
          .eq('user_id', userId)
          .eq('chats.trip_id', tripId)
          .single();

      log(res.toString());

      await supabaseClient.from('chat_members').update({
        'available': available,
      }).eq('id', res['id']);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
