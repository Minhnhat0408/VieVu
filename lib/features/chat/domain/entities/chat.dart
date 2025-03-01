class Chat {
  final int id;
  final String name;
  final String imageUrl;

  final String? tripId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  // final List<Map<String, dynamic>>? summarizeItineraries;
  // final int? lastSummarizedMessageId;
  bool isSeen;

  Chat({
    required this.id,
    required this.name,
    // required this.summarizeItineraries,
    // required this.lastSummarizedMessageId,
    this.tripId,
    required this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    required this.isSeen,
  });
}

class ChatSummarize {
  final int chatId;
  final String tripId;
  final DateTime createdAt;
  final List<Map<String, dynamic>> summary;
  final int lastMessageId;


  ChatSummarize({
    required this.chatId,
    required this.tripId,
    required this.createdAt,
    required this.summary,
    required this.lastMessageId,
  });
}
