import 'package:vn_travel_companion/features/search/domain/entities/home_search_result.dart';

class HomeSearchResultModel extends HomeSearchResult {
  HomeSearchResultModel({
    required super.id,
    required super.name,
     super.cover,
    required super.type,
    super.locations,
  });

  factory HomeSearchResultModel.fromJson(Map<String, dynamic> json) =>
      HomeSearchResultModel(
        id: json["id"],
        name: json["result_name"],
        cover: json["result_cover"],
        type: json["entity_type"],
        locations: json["locations"],
      );
}
