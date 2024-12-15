part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

class ExploreSearch extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;

  ExploreSearch({
    required this.searchText,
    required this.limit,
    required this.offset,
  });
}


