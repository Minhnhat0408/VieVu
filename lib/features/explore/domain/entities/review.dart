class Review {
  final int id;
  final String title;
  final String nickName;
  final String avatar;
  final String tripType;
  final int contentSize;
  final String content;
  final double score;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.title,
    required this.nickName,
    required this.avatar,
    required this.tripType,
    required this.contentSize,
    required this.content,
    required this.score,
    required this.createdAt,
  });
}
