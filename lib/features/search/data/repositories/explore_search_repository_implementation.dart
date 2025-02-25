import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/search/data/datasources/search_remote_datasource.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/domain/repositories/explore_search_repository.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/saved_service_remote_datasource.dart';

class ExploreSearchRepositoryImpl implements ExploreSearchRepository {
  final SearchRemoteDataSource searchRemoteDataSource;
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final ConnectionChecker connectionChecker;
  ExploreSearchRepositoryImpl({
    required this.searchRemoteDataSource,
    required this.savedServiceRemoteDatasource,
    required this.connectionChecker,
  });
  @override
  Future<Either<Failure, List<ExploreSearchResult>>> searchAll({
    required String searchText,
    required int limit,
    String? tripId,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      var searchResults = await searchRemoteDataSource.searchAll(
        searchText: searchText,
        limit: limit,
        offset: offset,
      );

      if (tripId != null) {
        log(tripId);
        final List<int> savedServiceIds = searchResults
            .map((e) => e.id)
            .toList()
            .cast<int>(); // convert to list of int
        final List<int> savedServiceIdsForTrip =
            await savedServiceRemoteDatasource.getListSavedServiceIdsForTrip(
          tripId: tripId,
          serviceIds: savedServiceIds,
        );

        searchResults = searchResults.map((e) {
          if (savedServiceIdsForTrip.contains(e.id)) {
            return e.copyWith(isSaved: true);
          }
          return e;
        }).toList();
      }

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> exploreSearch({
    required String searchText,
    required int limit,
    String? tripId,
    required int offset,
    String searchType = 'all',
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      var searchResults = await searchRemoteDataSource.exploreSearch(
        searchText: searchText,
        limit: limit,
        offset: offset,
        searchType: searchType,
      );

      if (tripId != null) {
        final List<int> savedServiceIds = searchResults
            .map((e) => e.id)
            .toList()
            .cast<int>(); // convert to list of int
        final List<int> savedServiceIdsForTrip =
            await savedServiceRemoteDatasource.getListSavedServiceIdsForTrip(
          tripId: tripId,
          serviceIds: savedServiceIds,
        );

        searchResults = searchResults.map((e) {
          if (savedServiceIdsForTrip.contains(e.id)) {
            return e.copyWith(isSaved: true);
          }
          return e;
        }).toList();
      }

      return right(searchResults);
    } catch (e) {
      throw left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExploreSearchResult>>> searchEvents({
    required String searchText,
    required int limit,
    String? tripId,
    required int page,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      var searchResults = await searchRemoteDataSource.searchEvents(
        searchText: searchText,
        limit: limit,
        page: page,
      );

      if (tripId != null) {
        final List<int> savedServiceIds = searchResults
            .map((e) => e.id)
            .toList()
            .cast<int>(); // convert to list of int
        final List<int> savedServiceIdsForTrip =
            await savedServiceRemoteDatasource.getListSavedServiceIdsForTrip(
          tripId: tripId,
          serviceIds: savedServiceIds,
        );

        searchResults = searchResults.map((e) {
          if (savedServiceIdsForTrip.contains(e.id)) {
            return e.copyWith(isSaved: true);
          }
          return e;
        }).toList();
      }

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
    String? tripId,
    required String searchType,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      var searchResults = await searchRemoteDataSource.searchExternalApi(
        searchText: searchText,
        limit: limit,
        page: page,
        searchType: searchType,
      );

      if (tripId != null) {
        final List<int> savedServiceIds = searchResults
            .map((e) => e.id)
            .toList()
            .cast<int>(); // convert to list of int
        final List<int> savedServiceIdsForTrip =
            await savedServiceRemoteDatasource.getListSavedServiceIdsForTrip(
          tripId: tripId,
          serviceIds: savedServiceIds,
        );

        searchResults = searchResults.map((e) {
          if (savedServiceIdsForTrip.contains(e.id)) {
            return e.copyWith(isSaved: true);
          }
          return e;
        }).toList();
      }
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
    int? linkId,
    String? externalLink,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
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
        return left(Failure("Không có kết nối mạng"));
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
