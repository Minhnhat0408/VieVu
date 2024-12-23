import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/review_model.dart';
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

// {
//     "ResponseStatus": {
//         "Timestamp": "/Date(1734922823424+0800)/",
//         "Ack": "Success",
//         "Extension": [
//             {
//                 "Id": "CLOGGING_TRACE_ID",
//                 "Value": "1515058298006074775"
//             },
//             {
//                 "Id": "RootMessageId",
//                 "Value": "100025527-0a9839ae-481923-52045"
//             }
//         ]
//     },
//     "isSupportLocale": true,
//     "score": 4.6,
//     "reviewscount": 0,
//     "pageIndex": 1,
//     "reviewList": [],
//     "tagFilterList": [
//         {
//             "tagId": 0,
//             "name": "Toàn bộ",
//             "count": 520
//         },
//         {
//             "tagId": -1,
//             "name": "Mới nhất",
//             "count": 0
//         },
//         {
//             "tagId": -21,
//             "name": "Có ảnh",
//             "count": 259
//         },
//         {
//             "tagId": -30,
//             "name": "Đơn đặt đã xác thực",
//             "count": 262
//         },
//         {
//             "tagId": -11,
//             "name": "Tích cực",
//             "count": 481
//         },
//         {
//             "tagId": -12,
//             "name": "Tiêu cực",
//             "count": 20
//         }
//     ],
//     "localeFilterList": [
//         {
//             "tagId": 0,
//             "name": "all",
//             "count": 0
//         },
//         {
//             "tagId": 1,
//             "name": "zh",
//             "count": 0
//         },
//         {
//             "tagId": 2,
//             "name": "en",
//             "count": 0
//         },
//         {
//             "tagId": 3,
//             "name": "ja",
//             "count": 0
//         },
//         {
//             "tagId": 4,
//             "name": "ko",
//             "count": 0
//         },
//         {
//             "tagId": 5,
//             "name": "th",
//             "count": 0
//         }
//     ],
//     "commentTagId": 1,
//     "localeTagId": 0,
//     "scoreName": "Nổi trội",
//     "jumpRNUrl": "/rn_ibu_gs_review/_crn_config?CRNModuleName=rn_ibu_gs_review&CRNType=1&transparentstatusbar=1&initialPage=ReviewList&sightId=23898595&commentTagId=1"
// }