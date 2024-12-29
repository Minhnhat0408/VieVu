part of 'search_history_cubit.dart';

@immutable
sealed class SearchHistoryState {}

final class SearchHistoryInitial extends SearchHistoryState {}

final class SearchHistoryLoading extends SearchHistoryState {}

final class SearchHistoryError extends SearchHistoryState {
  final String message;

  SearchHistoryError({
    required this.message,
  });
}

final class SearchHistorySuccess extends SearchHistoryState {
  final List<ExploreSearchResult> searchHistory;

  SearchHistorySuccess({
    required this.searchHistory,
  });
}