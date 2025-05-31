import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/utils/bm25_ranker.dart';
import 'package:vievu/features/search/data/models/explore_search_result_model.dart';
import 'package:http/http.dart' as http;
import 'package:vievu/features/search/data/models/home_search_result_model.dart';
import 'dart:math' as math; // For Math.log if you use a more standard IDF

abstract interface class SearchRemoteDataSource {
  Future<List<ExploreSearchResultModel>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
    String searchType = 'all',
  });

  Future<List<ExploreSearchResultModel>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
  });

  Future<List<ExploreSearchResultModel>> searchAllLocal({
    required String searchText,
    required int limit,
    required int offset,
  });

  Future<List<ExploreSearchResultModel>> searchEvents({
    required String searchText,
    required int limit,
    required int page,
  });

  Future<List<HomeSearchResultModel>> searchHome({
    required String searchText,
    required int limit,
    required int offset,
    String? searchType,
  });

  Future<List<ExploreSearchResultModel>> searchExternalApi({
    required String searchText,
    required int limit,
    required int page,
    required String searchType,
  });

  Future upsertSearchHistory({
    String? searchText,
    String? cover,
    required String userId,
    String? title,
    String? address,
    int? linkId,
    String? externalLink,
  });

  Future<List<ExploreSearchResultModel>> getSearchHistory({
    required String userId,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;
  final http.Client client;
  final BM25Ranker bm25ranker;
  SearchRemoteDataSourceImpl(
    this.supabaseClient,
    this.client,
    this.bm25ranker,
  );

  @override
  Future<List<ExploreSearchResultModel>> searchAllLocal({
    required String searchText,
    required int limit, // This is the overall limit for the final result
    required int offset, // This offset is for the *final combined and ranked* list
  }) async {
    log('searchAll (Flutter client-side): searchText="$searchText", overallLimit=$limit, overallOffset=$offset');
    try {
      // For client-side aggregation, we usually fetch more initially from each source
      // and then apply offset/limit *after* ranking.
      // The Python code distributed the limit *before* fetching.
      // Here, we'll fetch a decent number from each, combine, rank, then apply offset & limit.

      // Define how many items to try fetching from each source.
      // These are not the final limits, but initial fetch sizes.
      // Adjust these based on typical result set sizes and performance.
      const int initialFetchLimitPerSource = 30; // Fetch up to 30 from each source initially
      const int initialPageForApis = 1; // Fetch from page 1 for APIs

      // Note: The original Python code calculated sub-limits and pages based on the *final* limit/offset.
      // If you want to strictly adhere to that, you'd need to pass the overall offset and limit
      // to this function and then calculate sub-limits/offsets for each call.
      // However, for client-side ranking, it's often better to fetch a bit more, then rank, then paginate.
      // The current implementation will fetch `initialFetchLimitPerSource` from each.
      // The provided `offset` and `limit` will be applied *after* combining and ranking.

      final List<Future<List<ExploreSearchResultModel>>> searchFutures = [
        searchEvents(
          searchText: searchText,
          limit: initialFetchLimitPerSource, // Fetch more initially
          page: initialPageForApis,
        ).catchError((e) {
          log("Error in searchEvents for searchAll: $e");
          return <ExploreSearchResultModel>[];
        }),
        exploreSearch( // Supabase RPC
          searchText: searchText,
          limit: initialFetchLimitPerSource, // Fetch more initially
          offset: 0, // Fetch from the beginning for Supabase
          searchType: "attractions",
        ).catchError((e) {
          log("Error in exploreSearch (attractions) for searchAll: $e");
          return <ExploreSearchResultModel>[];
        }),
        exploreSearch( // Supabase RPC
          searchText: searchText,
          limit: initialFetchLimitPerSource, // Fetch more initially
          offset: 0, // Fetch from the beginning
          searchType: "locations",
        ).catchError((e) {
          log("Error in exploreSearch (locations) for searchAll: $e");
          return <ExploreSearchResultModel>[];
        }),
        searchExternalApi( // Trip.com
          searchText: searchText,
          limit: initialFetchLimitPerSource, // Fetch more initially
          page: initialPageForApis,
          searchType: "hotel",
        ).catchError((e) {
          log("Error in searchExternalApi (hotel) for searchAll: $e");
          return <ExploreSearchResultModel>[];
        }),
        searchExternalApi( // Trip.com
          searchText: searchText,
          limit: initialFetchLimitPerSource, // Fetch more initially
          page: initialPageForApis,
          searchType: "restaurant",
        ).catchError((e) {
          log("Error in searchExternalApi (restaurant) for searchAll: $e");
          return <ExploreSearchResultModel>[];
        }),
      ];

      final List<List<ExploreSearchResultModel>> resultsFromAllSources =
          await Future.wait(searchFutures);

      final List<ExploreSearchResultModel> combinedResults = [];
      for (final list in resultsFromAllSources) {
        combinedResults.addAll(list);
      }

      if (combinedResults.isEmpty) {
        log('searchAll: No results found from any source.');
        return [];
      }
      log('searchAll: Combined ${combinedResults.length} results before ranking.');

      // Deduplication (simple example based on title and address, make it more robust)
      final Set<String> uniqueKeys = {};
      final List<ExploreSearchResultModel> deduplicatedResults = [];
      for (final item in combinedResults) {
        String key = "${item.title?.toLowerCase()}_${item.address?.toLowerCase()}";
        if (item.externalLink != null && item.externalLink!.isNotEmpty) {
            key = item.externalLink!; // Prefer external link if available for uniqueness
        } 

        if (uniqueKeys.add(key)) {
          deduplicatedResults.add(item);
        }
      }
      log('searchAll: Deduplicated to ${deduplicatedResults.length} results.');


      List<ExploreSearchResultModel> rankedResults;
      if (searchText.trim().isNotEmpty) {
        log('searchAll: Applying BM25 ranking for query: "$searchText"');
        rankedResults = bm25ranker.rank(query: searchText, documents: deduplicatedResults);
      } else {
        rankedResults = List.from(deduplicatedResults); // No query, no specific ranking
      }
      log('searchAll: Ranked ${rankedResults.length} results.');

      // Apply overall offset and limit to the ranked results
      List<ExploreSearchResultModel> finalPaginatedResults = [];
      if (offset < rankedResults.length) {
        final int end = math.min(offset + limit, rankedResults.length);
        finalPaginatedResults = rankedResults.sublist(offset, end);
      } else if (limit == 0) {
         finalPaginatedResults = [];
      }


      log('searchAll: Returning ${finalPaginatedResults.length} final paginated results.');
      return finalPaginatedResults;

    } catch (e, s) {
      log("Critical error in client-side searchAll: ${e.toString()}", stackTrace: s);
      throw ServerException("Failed to execute client-side searchAll: ${e.toString()}");
    }
  }

  @override
  Future<List<HomeSearchResultModel>> searchHome({
    required String searchText,
    required int limit,
    required int offset,
    String? searchType,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception("User not found");
      }
      final response =
          await supabaseClient.rpc('search_profiles_and_trips', params: {
        'keyword': searchText,
        'result_limit': limit,
        'result_offset': offset,
        'search_type': searchType,
      });
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);
      return data.map((e) => HomeSearchResultModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ExploreSearchResultModel>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      final session = supabaseClient.auth.currentSession;
      if (session == null || user == null) {
        throw const ServerException('Không thể xác thực người dùng');
      }
      final token = session.accessToken;

      final url =
          Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/search_all');

      final body = {
        "search_text": searchText,
        "limit": limit,
        "offset": offset
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final jsonResponse = utf8.decode(response.bodyBytes);
      final eventData = json.decode(
        jsonResponse,
      );
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(eventData['results']);

      return data.map((e) => ExploreSearchResultModel.fromJson(e)).toList();
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
              'id': event['originalId'],
              'external_link': event['deeplink'],
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

  @override
  Future upsertSearchHistory({
    String? searchText,
    String? cover,
    required String userId,
    String? title,
    String? address,
    int? linkId,
    String? externalLink,
  }) async {
    try {
      final compareLinkId =
          linkId != null ? "link_id.eq.$linkId" : "link_id.is.null";
      final response = await supabaseClient
          .from('search_history')
          .select('id')
          .eq('user_id', userId)
          .or('keyword.eq.$searchText,and( title.eq.$title, $compareLinkId)');

      if (response.isEmpty) {
        await supabaseClient.from('search_history').insert({
          'keyword': searchText,
          'cover': cover,
          'user_id': userId,
          'title': title,
          'created_at': DateTime.now().toIso8601String(),
          'address': address,
          'has_detail': cover != null,
          'link_id': linkId,
          'external_link': externalLink,
        });
      } else {
        await supabaseClient.from('search_history').update({
          'created_at': DateTime.now().toIso8601String(),
        }).eq('id', response[0]['id']);
      }
    } catch (e) {
      log(e.toString());

      throw Exception(e.toString());
    }
  }

  @override
  Future<List<ExploreSearchResultModel>> getSearchHistory({
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from('search_history')
          .select('*')
          .eq('user_id', userId)
          .limit(10)
          .order('created_at', ascending: false);

      return response
          .map((e) => ExploreSearchResultModel.fromSearchHistoryJson(e))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
