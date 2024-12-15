import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

class ExploreSearchResultModel extends ExploreSearchResult {
  ExploreSearchResultModel({
    required super.title,
    super.address,
    required super.id,
    required super.type,
    super.cover,
  });

  factory ExploreSearchResultModel.fromJson(Map<String, dynamic> json) {
    return ExploreSearchResultModel(
      title: json['title'],
      address: json['address'],
      id: json['id'],
      type: json['table_name'],
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
    };
  }


}
