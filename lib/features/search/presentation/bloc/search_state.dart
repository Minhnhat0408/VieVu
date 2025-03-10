part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchError extends SearchState {
  final String message;

  SearchError({
    required this.message,
  });
}

final class SearchSuccess extends SearchState {
  final List<ExploreSearchResult> results;

  SearchSuccess({
    required this.results,
  });
}

final class SearchOverAllSuccess extends SearchState {
  final List<ExploreSearchResult> results;

  SearchOverAllSuccess({
    required this.results,
  });
}

final class SearchHomeSuccess extends SearchState {
  final List<HomeSearchResult> results;

  SearchHomeSuccess({
    required this.results,
  });
}
