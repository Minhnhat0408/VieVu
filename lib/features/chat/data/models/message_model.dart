import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.chatId,
    required super.content,
    required super.createdAt,
    super.metaData,
    required super.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      metaData: json['meta_data'] != null
          ? List<Map<String, dynamic>>.from(json['meta_data'])
          : null,
      user: UserModel.fromJson(json['profiles']),
    );
  }
}
