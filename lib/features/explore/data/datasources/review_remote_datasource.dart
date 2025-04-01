import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/explore/data/models/review_model.dart';
import 'package:http/http.dart' as http;

abstract interface class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getAttractionReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
    required int commentTagId,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReviewRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ReviewModel>> getAttractionReviews({
    required int attractionId,
    required int limit,
    required int pageIndex,
    required int commentTagId,
  }) async {
    final url =
        Uri.parse('https://vn.trip.com/restapi/soa2/19707/getReviewSearch');
    final body = {
      "poiId": attractionId,
      "locale": "vi-VN",
      "pageSize": limit,
      "pageIndex": pageIndex,
      "commentTagId": commentTagId,
      "head": {
        "locale": "vi-VN",
        "cver": "3.0",
        "extension": [
          {"name": "locale", "value": "vi-VN"},
          {"name": "platform", "value": "Online"},
          {"name": "currency", "value": "USD"},
          {"name": "aid", "value": ""}
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

      final jsonResponse = jsonDecode(response.body);

      final reviews = jsonResponse['reviewList'] as List;

      return reviews
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
