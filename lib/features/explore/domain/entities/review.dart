class Review {
  final int id;
  final String nickName;
  final String avatar;

  final String content;
  final double score;
  final String scoreName;
  final String? tagName;
  final List<String> images;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.nickName,
    required this.avatar,
    required this.content,
    required this.score,
    required this.createdAt,
    required this.images,
    required this.scoreName,
    this.tagName,
  });
}
