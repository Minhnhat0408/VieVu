import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/search/data/datasources/search_remote_datasource.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/domain/repositories/explore_search_repository.dart';

class ExploreSearchRepositoryImpl implements ExploreSearchRepository {
  final SearchRemoteDataSource searchRemoteDataSource;
  final ConnectionChecker connectionChecker;
  ExploreSearchRepositoryImpl(
    this.searchRemoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> exploreSearch({
    required String searchText,
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final List<ExploreSearchResult> searchResults =
          await searchRemoteDataSource.exploreSearch(
        searchText: searchText,
        limit: limit,
        offset: offset,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }
}
