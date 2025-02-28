import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';

class Message {
  final int id;
  final int chatId;
  String content;
  final User user;
  final DateTime createdAt;
  List<Map<String, dynamic>>? metaData;
  List<User>? seenUser;

  Message({
    required this.id,
    required this.chatId,
    required this.content,
    required this.user,
    required this.createdAt,
    this.metaData,
    this.seenUser,
  });
}
