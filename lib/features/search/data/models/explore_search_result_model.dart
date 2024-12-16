import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

class ExploreSearchResultModel extends ExploreSearchResult {
  ExploreSearchResultModel({
    required super.title,
    super.address,
    required super.id,
    required super.type,
    super.cover,
    super.ratingCount,
    super.avgRating,
    super.hotScore,
  });

  factory ExploreSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ExploreSearchResultModel(
      title: json['title'],
      address: json['address'],
      id: json['id'],
      type: json['table_name'],
      cover: json['cover'],
      ratingCount: json['rating_count'],
      avgRating: json['avg_rating']?.toDouble(),
      hotScore: json['hot_score']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'address': address,
      'id': id,
      'type': type,
      'cover': cover,
      'rating_count': ratingCount,
      'avg_rating': avgRating,
      'hot_score': hotScore,
    };
  }

  ExploreSearchResultModel copyWith({
    String? title,
    String? address,
    String? id,
    String? type,
    String? cover,
    int? ratingCount,
    double? avgRating,
    double? hotScore,
  }) {
    return ExploreSearchResultModel(
      title: title ?? this.title,
      address: address ?? this.address,
      id: id ?? this.id,
      type: type ?? this.type,
      cover: cover ?? this.cover,
      ratingCount: ratingCount ?? this.ratingCount,
      avgRating: avgRating ?? this.avgRating,
      hotScore: hotScore ?? this.hotScore,
    );
  }
}
