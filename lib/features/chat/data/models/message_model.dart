import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.chatId,
    required super.content,
    required super.createdAt,
    super.metaData,
    super.seenUser,
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
      seenUser: json['seen_user'] != null
          ? List<UserModel>.from(json['seen_user'])
          : null,
    );
  }

  MessageModel copyWith({
    int? id,
    int? chatId,
    String? content,
    DateTime? createdAt,
    List<Map<String, dynamic>>? metaData,
    List<UserModel>? seenUser,
    UserModel? user,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      metaData: metaData ?? this.metaData,
      seenUser: seenUser != null
          ? seenUser.isNotEmpty
              ? seenUser
              : this.seenUser
          : this.seenUser,
      user: user ?? this.user,
    );
  }
}
