import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/search/data/models/explore_search_result_model.dart';
import 'package:http/http.dart' as http;

abstract interface class SearchRemoteDataSource {
  Future<List<ExploreSearchResultModel>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
    String searchType = 'all',
  });

  Future<List<ExploreSearchResultModel>> searchEvents({
    required String searchText,
    required int limit,
    required int page,
  });

  Future<List<ExploreSearchResultModel>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
  });

  Future<List<ExploreSearchResultModel>> searchExternalApi({
    required String searchText,
    required int limit,
    required int page,
    required String searchType,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;
  final http.Client client;
  SearchRemoteDataSourceImpl(
    this.supabaseClient,
    this.client,
  );

  @override
  Future<List<ExploreSearchResultModel>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await exploreSearch(
          searchText: searchText, limit: limit, offset: offset);

      final events =
          await searchEvents(searchText: searchText, limit: limit, page: 1);

      return [...response, ...events];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ExploreSearchResultModel>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
    String searchType = 'all',
  }) async {
    try {
      final response = await supabaseClient.rpc('search_unaccent', params: {
        'search_query': searchText,
        'lim': limit,
        'off_set': offset,
        'search_type': searchType,
      });
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);
      return data.map((e) => ExploreSearchResultModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ExploreSearchResultModel>> searchEvents({
    required String searchText,
    required int limit,
    required int page,
  }) async {
    try {
      final url = Uri.parse(
          'https://api-v2.ticketbox.vn/search/v2/events?limit=$limit&page=$page&q=$searchText');

      final ticketBox = await client.get(url);
      final data = [];
      if (ticketBox.statusCode == 200) {
        final decodedBody = utf8.decode(ticketBox.bodyBytes);
        final eventData = json.decode(
          decodedBody,
        );
        for (var event in eventData['data']['results']) {
          final eventId = event['originalId'];
          final detailsUrl = Uri.parse(
              'https://api-v2.ticketbox.vn/gin/api/v1/events/$eventId');
          final detailEvent = await client.get(
            detailsUrl,
            headers: {'x-accept-language': 'vi'}, // Add language header
          );
          if (detailEvent.statusCode == 200) {
            final decodedBodyDetails = utf8.decode(detailEvent.bodyBytes);
            final details = json.decode(
              decodedBodyDetails,
            );

            data.add({
              'title': event['name'],
              'address': details['data']['result']['address'],
              'id': event['deeplink'],
              'table_name': 'event',
              'cover': event['imageUrl'],
            });
          }
        }
      }

      return data.map((e) => ExploreSearchResultModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ExploreSearchResultModel>> searchExternalApi({
    required String searchText,
    required int limit,
    required int page,
    required String searchType,
  }) async {
    try {
      final url = Uri.parse(
          'https://www.trip.com/restapi/soa2/20400/getGsMainResultForTripOnline');
      final body = {
        "keyword": searchText,
        "lang": "vn",
        "locale": "vi-VN",
        "currency": "VND",
        "pageIndex": page,
        "pageSize": limit,
        "tab": searchType,
        "head": {
          "cver": "3.0",
          "syscode": "999",
          "locale": "vi-VN",
          "extension": [
            {"name": "locale", "value": "vi-VN"},
            {"name": "platform", "value": "Online"},
            {"name": "currency", "value": "VND"}
          ]
        }
      };
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Specify the content type
        },
        body: jsonEncode(body), // Convert the body to JSON
      );

      final jsonResponse = jsonDecode(response.body);

      final data = jsonResponse['data'];
      if (data == null) {
        throw Exception('No data found');
      }

      final reviews = data[0]['itemList'] as List;
      final filteredReviews = reviews
          .where((item) => item['districtName'].contains('Việt Nam'))
          .toList();

      return filteredReviews
          .map((item) => ExploreSearchResultModel.fromExternalJson(
              item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
