part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}
class SearchAll extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;
  final String? tripId;

  SearchAll({
     this.tripId,
    required this.searchText,
    required this.limit,
    required this.offset,

  });
}

class SearchAllLocal extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;
  final String? tripId;

  SearchAllLocal({
     this.tripId,
    required this.searchText,
    required this.limit,
    required this.offset,

  });
}



class ExploreSearch extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;
  final String searchType;
  final String? tripId;

  ExploreSearch({
     this.tripId,
    required this.searchText,
    required this.limit,
    required this.offset,
    required this.searchType,
  });
}

class EventsSearch extends SearchEvent {
  final String searchText;
  final int limit;
  final int page;
  final String? tripId;

  EventsSearch({
     this.tripId,
    required this.searchText,
    required this.limit,
    required this.page,
  });
}

class SearchExternalApi extends SearchEvent {
  final String searchText;
  final int limit;
  final String? tripId;
  final int page;
  final String searchType;

  SearchExternalApi({
    required this.searchText,
     this.tripId,
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
  final int? linkId;
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


class SearchHome extends SearchEvent {
  final String searchText;
  final int limit;
  final int offset;
  final String? searchType;

  SearchHome({
    required this.searchText,
    required this.limit,
    required this.offset,
    this.searchType,
  });
}
