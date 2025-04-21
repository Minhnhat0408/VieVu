import 'package:vievu/features/chat/domain/entities/chat.dart';

class ChatModel extends Chat {
  ChatModel({
    required super.id,
    required super.name,
    required super.chatMemberId,
    super.imageUrl,
    super.lastMessage,
    super.lastMessageTime,
    super.tripId,
    super.lastSeenUserAvatar,
    required super.isSeen,

  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['chat_id'] ?? json['id'],
      tripId: json['trip_id'],
      chatMemberId: json['chat_member_id'],
      name: json['chat_name'],
      lastSeenUserAvatar: json['last_seen_user_avatar'],
      imageUrl: json['chat_avatar'],
      lastMessage: json['last_message'] ??
          (json['last_message_time'] != null ? 'Tin nhắn đã bị gỡ' : null),
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      isSeen: json['is_seen'] ?? false,
    );
  }
}

class ChatSummarizeModel extends ChatSummarize {
  ChatSummarizeModel({
    required super.chatId,
    required super.createdAt,
    required super.tripId,
    required super.summary,
    required super.readings,
    required super.lastMessageId,
    required super.isConverted,
  });

  factory ChatSummarizeModel.fromJson(Map<String, dynamic> json) {
    return ChatSummarizeModel(
      isConverted: json['is_converted'] ?? false,
      tripId: json['trip_id'] ?? json['chats']['trip_id'],
      chatId: json['chat_id'],
      readings: json['readings'],
      createdAt: DateTime.parse(json['updated_at']),
      summary: json['summary'] != null
          ? List<Map<String, dynamic>>.from(json['summary'])
          : [],
      lastMessageId: json['last_message_id'],
    );
  }
}
