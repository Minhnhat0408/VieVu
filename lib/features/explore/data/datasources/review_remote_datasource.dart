import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/review_model.dart';
import 'package:http/http.dart' as http;

abstract interface class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getAttractionReviews({
    required String attractionId,
    required int limit,
    required int pageIndex,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReviewRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ReviewModel>> getAttractionReviews({
    required String attractionId,
    required int limit,
    required int pageIndex,
  }) async {
    final url =
        Uri.parse('https://vn.trip.com/restapi/soa2/19707/getTACommentList');
    final body = {
      "arg": {
        "poiId": attractionId,
        "resourceId": 0,
        "resourceType": 0,
        "sortType": 0,
        "sourceType": 101,
        "pageIndex": pageIndex,
        "pageSize": limit,
        "locale": "vi-VN"
      },
      "head": {
        "locale": "vi-VN",
        "cver": "3.0",
        "cid": "",
        "sid": "",
        "extension": [
          {"name": "locale", "value": "vi-VN"},
          {"name": "platform", "value": "Online"},
          {"name": "currency", "value": "USD"},
          {"name": "aid", "value": ""},
        ]
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Specify the content type
        },
        body: jsonEncode(body), // Convert the body to JSON
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final reviewList =
            jsonResponse['result']['commentInfoTypes'] as List<dynamic>;

        return reviewList
            .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
