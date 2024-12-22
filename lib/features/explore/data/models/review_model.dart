import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.title,
    required super.nickName,
    required super.avatar,
    required super.tripType,
    required super.contentSize,
    required super.content,
    required super.score,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['publishTime'] as String;
    final regex = RegExp(r"\/Date\((\d+)([+-]\d{4})?\)\/");
    final match = regex.firstMatch(dateString);
    if (match == null) {
      throw Exception('Invalid date string: $dateString');
    }
    final timestamp = int.parse(match.group(1)!);
    final offsetString = match.group(2);

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (offsetString != null) {
      final offsetHours = int.parse(offsetString.substring(1, 3));
      final offsetMinutes = int.parse(offsetString.substring(3, 5));
      final offset = Duration(
        hours: offsetHours,
        minutes: offsetMinutes,
      );
      dateTime = offsetString.startsWith('+')
          ? dateTime.add(offset)
          : dateTime.subtract(offset);
    }

    return ReviewModel(
      id: json['id'],
      title: json['title'],
      nickName: json['nickName'],
      avatar: json['headPhoto'],
      tripType: json['tripType'],
      contentSize: json['contentSize'],
      content: json['content'],
      score: json['score'],
      createdAt: dateTime,
    );
  }
}
