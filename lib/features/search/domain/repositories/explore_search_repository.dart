import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';

abstract interface class ExploreSearchRepository {
  Future<Either<Failure,List<ExploreSearchResult>>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
  });
}