import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

class ExploreSearchResultModel extends ExploreSearchResult {
  ExploreSearchResultModel({
    required super.title,
    super.address,
    super.isSaved = false,
    required super.id,
    required super.type,
    super.externalLink,
    super.cover,
    super.locationName,
    super.ratingCount,
    super.avgRating,
    super.hotScore,
    super.price,
  });

  factory ExploreSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ExploreSearchResultModel(
      title: json['title'],
      address: json['address'],
      id: json['id'] is String
          ? int.tryParse(json['id']) != null
              ? int.parse(json['id'])
              : int.parse((json['id'] as String).replaceAll('-', ''))
          : json['id'],
      type: json['table_name'],
      cover: json['cover'],
      price: json['price'],
      ratingCount: json['rating_count'],
      avgRating: json['avg_rating']?.toDouble(),
      hotScore: json['hot_score']?.toDouble(),
    );
  }

  factory ExploreSearchResultModel.fromExternalJson(Map<String, dynamic> json) {
    return ExploreSearchResultModel(
      title: json['word'],
      address: json['districtName'],
      id: json['id'],
      locationName: json['districtName'] is String
          ? (() {
              List<String> parts = (json['districtName'] as String).split(', ');
              return parts.length >= 2 ? parts[parts.length - 2] : parts[0];
            })()
          : json['cityName'],
      type: json['type'],
      price: json['priceInfo'] != null
          ? json['priceInfo']['price']?.toInt()
          : null,
      cover: json['imageUrl'],
      externalLink: json['url'],
      ratingCount: json['commentCount'],
      avgRating: json['commentScore']?.toDouble(),
      hotScore: json['hot_score']?.toDouble(),
    );
  }

  factory ExploreSearchResultModel.fromSearchHistoryJson(
      Map<String, dynamic> json) {
    return ExploreSearchResultModel(
      title: json['title'] ?? json['keyword'],
      address: json['address'],
      id: json['link_id'] ?? 0,
      externalLink: json['external_link'],
      type: json['has_detail']
          ? json['link_id'] != null
              ? 'attractions'
              : 'restaurant'
          : json['keyword'] != null
              ? 'keyword'
              : 'locations',
      cover: json['cover'],
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
    int? id,
    String? externalLink,
    String? type,
    bool? isSaved,
    String? cover,
    int? ratingCount,
    double? avgRating,
    double? hotScore,
  }) {
    return ExploreSearchResultModel(
      title: title ?? this.title,
      address: address ?? this.address,
      id: id ?? this.id,
      externalLink: externalLink ?? this.externalLink,
      type: type ?? this.type,
      isSaved: isSaved ?? this.isSaved,
      cover: cover ?? this.cover,
      ratingCount: ratingCount ?? this.ratingCount,
      avgRating: avgRating ?? this.avgRating,
      hotScore: hotScore ?? this.hotScore,
    );
  }
}
