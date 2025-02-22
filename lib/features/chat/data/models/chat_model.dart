import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';

class ChatModel extends Chat {
  ChatModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.lastMessage,
    super.lastMessageTime,
    required super.isGroup,
    required super.isSeen,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['chat_id'],
      name: json['chat_name'],
      imageUrl: json['chat_avatar'],
      isGroup: json['is_group'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      isSeen: json['is_seen'],
    );
  }
}
