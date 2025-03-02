import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.chatId,
    required super.content,
    required super.createdAt,
    required super.reactions,
    super.metaData,
    super.seenUser,
    required super.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      reactions: json['message_reactions'] != null
          ? List<MessageReactionModel>.from(
              json['message_reactions'].map((x) => MessageReactionModel.fromJson(x)))
          : [],
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
    List<MessageReactionModel>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      reactions: reactions ?? this.reactions,
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

class MessageReactionModel extends MessageReaction {
  MessageReactionModel({
    required super.messageId,
    required super.user,
    required super.reaction,
    required super.id
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      messageId: json['message_id'],
      user: UserModel.fromJson(json['profiles']),
      reaction: json['reaction'],
      id: json['id'],
    );
  }

  MessageReactionModel copyWith({
    int? messageId,
    UserModel? user,
    String? reaction,
    int? id,
  }) {
    return MessageReactionModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      user: user ?? this.user,
      reaction: reaction ?? this.reaction,
    );
  }
}
