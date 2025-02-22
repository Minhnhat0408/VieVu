class Chat {
  final int id;
  final String name;
  final String imageUrl;
  final bool isGroup;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isSeen;

  Chat({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isGroup,
    this.lastMessage,
    this.lastMessageTime,
    required this.isSeen,
  });
}
