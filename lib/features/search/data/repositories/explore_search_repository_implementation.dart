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
    String searchType = 'all',
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
        searchType: searchType,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> searchEvents({
    required String searchText,
    required int limit,
    required int page,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final List<ExploreSearchResult> searchResults =
          await searchRemoteDataSource.searchEvents(
        searchText: searchText,
        limit: limit,
        page: page,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> searchAll({
    required String searchText,
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final List<ExploreSearchResult> searchResults =
          await searchRemoteDataSource.searchAll(
        searchText: searchText,
        limit: limit,
        offset: offset,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> searchExternalApi({
    required String searchText,
    required int limit,
    required int page,
    required String searchType,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final List<ExploreSearchResult> searchResults =
          await searchRemoteDataSource.searchExternalApi(
        searchText: searchText,
        limit: limit,
        page: page,
        searchType: searchType,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> upsertSearchHistory({
    String? searchText,
    String? cover,
    required String userId,
    String? title,
    String? address,
    String? linkId,
    String? externalLink,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      await searchRemoteDataSource.upsertSearchHistory(
        searchText: searchText,
        cover: cover,
        userId: userId,
        title: title,
        address: address,
        linkId: linkId,
        externalLink: externalLink,
      );

      return right(true);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> getSearchHistory({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }
      final List<ExploreSearchResult> searchResults =
          await searchRemoteDataSource.getSearchHistory(
        userId: userId,
      );

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }
}
