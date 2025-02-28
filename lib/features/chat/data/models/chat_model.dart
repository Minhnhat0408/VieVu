import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';

class ChatModel extends Chat {
  ChatModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.lastMessage,
    super.lastMessageTime,
    super.tripId,
    required super.isSeen,
    // required super.summarizeItineraries,
    // required super.lastSummarizedMessageId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['chat_id'],
      tripId: json['trip_id'],
      name: json['chat_name'],
      imageUrl: json['chat_avatar'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      isSeen: json['is_seen'],
      // summarizeItineraries: json['summarize_itineraries'],
      // lastSummarizedMessageId: json['last_summarized_message_id'],
    );
  }
}

class ChatSummarizeModel extends ChatSummarize {
  ChatSummarizeModel({
    required super.chatId,
    required super.createdAt,
    required super.summary,
    required super.lastMessageId,
  });

  factory ChatSummarizeModel.fromJson(Map<String, dynamic> json) {
    return ChatSummarizeModel(
      chatId: json['chat_id'],
      createdAt: DateTime.parse(json['updated_at']),
      summary: json['summary'] != null
          ? List<Map<String, dynamic>>.from(json['summary'])
          : [],
      lastMessageId: json['last_message_id'],
    );
  }
}
