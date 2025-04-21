class Chat {
  final int id;
  final String name;
  final String?  imageUrl;
  final int chatMemberId;
  final String? tripId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSeenUserAvatar;
  bool isSeen;

  Chat({
    required this.id,
    required this.name,
    required this.chatMemberId,

    this.tripId,
     this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSeenUserAvatar,
    required this.isSeen,
  });
}

class ChatSummarize {
  final int chatId;
  final String tripId;
  final bool isConverted;
  final String readings;
  final DateTime createdAt;
  final List<Map<String, dynamic>> summary;
  final int lastMessageId;

  ChatSummarize({
    required this.isConverted,
    required this.chatId,
    required this.readings,
    required this.tripId,
    required this.createdAt,
    required this.summary,
    required this.lastMessageId,
  });
}
