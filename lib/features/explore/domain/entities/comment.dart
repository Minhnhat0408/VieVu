class Comment {
  final int poiId;
  final String poiName;
  final String name;
  final String avatar;
  final String content;
  final String cover;

  Comment({
    required this.poiId,
    required this.poiName,
    required this.name,
    required this.avatar,
    required this.content,
    required this.cover,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      poiId: json['poiId'],
      poiName: json['name'],
      name: json['authorInfo']['authorName'],
      avatar: json['authorInfo']['avatar'],
      content: json['comment'],
      cover: json['coverImage'],
    );
  }
}
