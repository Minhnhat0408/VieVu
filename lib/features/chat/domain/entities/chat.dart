class Chat {
  final int id;
  final String name;
  final String imageUrl;

  final String? tripId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  bool isSeen;

  Chat({
    required this.id,
    required this.name,
    this.tripId,
    required this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    required this.isSeen,
  });
}
