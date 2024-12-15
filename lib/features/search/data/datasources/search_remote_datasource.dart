import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/search/data/models/explore_search_result_model.dart';

abstract interface class SearchRemoteDataSource {
  Future<List<ExploreSearchResultModel>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;

  SearchRemoteDataSourceImpl(
    this.supabaseClient,
  );

  @override
  Future<List<ExploreSearchResultModel>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient.rpc('search_unaccent', params: {
        'search_query': searchText,
        'lim': limit,
        'off_set': offset,
      });
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      return data.map((e) => ExploreSearchResultModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
