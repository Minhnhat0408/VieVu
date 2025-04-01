import 'package:vievu/features/auth/domain/entities/user.dart';

class Message {
  final int id;
  final int chatId;
  String content;
  final User user;
  final DateTime createdAt;
  final List<MessageReaction> reactions;
  List<Map<String, dynamic>>? metaData;
  List<User>? seenUser;

  Message({
    required this.id,
    required this.reactions,
    required this.chatId,
    required this.content,
    required this.user,
    required this.createdAt,
    this.metaData,
    this.seenUser,
  });
}

class MessageReaction {
  final int id;
  final int messageId;
  final User user;
  final String reaction;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.user,
    required this.reaction,
  });
}
