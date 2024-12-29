import 'package:html_unescape/html_unescape.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.nickName,
    required super.avatar,
    required super.content,
    required super.score,
    required super.createdAt,
    required super.images,
    required super.scoreName,
    super.tagName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int createTime = json['createTime']; // Timestamp in milliseconds
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(createTime);
    final unescape = HtmlUnescape();
    String encodedText = json['translateContent'] ?? json['content'];
    String decodedText = unescape.convert(encodedText);
    return ReviewModel(
      id: json['reviewId'],
      nickName: json['username'] ?? '',
      avatar: json['headImage'] ?? '',
      content: decodedText,
      score: json['userRating'],
      createdAt: dateTime,
      images: json['reviewImages'].cast<String>(),
      scoreName: json['scoreName'] ?? '',
      tagName: json['tagName'],
    );
  }
}
