import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

abstract interface class ExploreSearchRepository {
    Future<Either<Failure,List<ExploreSearchResult>>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
    String? tripId,
  });
  Future<Either<Failure,List<ExploreSearchResult>>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
    String? tripId,
    String searchType = 'all',
  });

  Future<Either<Failure,List<ExploreSearchResult>>> searchEvents({
    required String searchText,
    required int limit,
    String? tripId,
    required int page,
  });



  Future<Either<Failure,List<ExploreSearchResult>>> searchExternalApi({
    required String searchText,
    required int limit,
    String? tripId,
    required int page,
    required String searchType,
  });

  Future<Either<Failure,bool>> upsertSearchHistory({
    String? searchText,
    String? cover,
    required String userId,
    String? title,
    String? address,
    int? linkId,
    String? externalLink,
  });

  Future<Either<Failure,List<ExploreSearchResult>>> getSearchHistory({
    required String userId,
  });

}
