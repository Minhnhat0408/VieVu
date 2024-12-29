part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

class ExploreSearch extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;
  final String searchType;

  ExploreSearch({
    required this.searchText,
    required this.limit,
    required this.offset,
    required this.searchType,
  });
}

class SearchAll extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;

  SearchAll({
    required this.searchText,
    required this.limit,
    required this.offset,
  });
}

class EventsSearch extends SearchEvent {
  final String searchText;
  final int limit;
  final int page;

  EventsSearch({
    required this.searchText,
    required this.limit,
    required this.page,
  });
}

class SearchExternalApi extends SearchEvent {
  final String searchText;
  final int limit;
  final int page;
  final String searchType;

  SearchExternalApi({
    required this.searchText,
    required this.limit,
    required this.page,
    required this.searchType,
  });
}

class SearchHistory extends SearchEvent {
  final String? searchText;
  final String userId;
  final String? cover;
  final String? title;
  final String? address;
  final String? linkId;
  final String? externalLink;

  SearchHistory({
    this.searchText,
    required this.userId,
    this.cover,
    this.title,
    this.address,
    this.linkId,
    this.externalLink,
  });
}