import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';

class Message {
  final int id;
  final int chatId;
  final String content;
  final User user;
  final DateTime createdAt;
  final Map<String, dynamic>? metaData;

  Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.user,
    required this.createdAt,
    this.metaData,
  });
}
