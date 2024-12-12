part of 'explore_bloc.dart';

@immutable
sealed class ExploreEvent {}

class GetAttraction extends ExploreEvent {
  final int attractionId;

  GetAttraction(this.attractionId);
}

class GetHotAttractions extends ExploreEvent {
  final int limit;
  final int offset;

  GetHotAttractions({required this.limit, required this.offset});
}

class GetRecentViewedAttractions extends ExploreEvent {
  final int limit;

  GetRecentViewedAttractions(this.limit);
}

class UpsertRecentViewedAttractions extends ExploreEvent {
  final int attractionId;
  final String userId;

  UpsertRecentViewedAttractions(this.attractionId, this.userId);
}

class GetLocation extends ExploreEvent {
  final int locationId;

  GetLocation(this.locationId);
}

class GetHotLocations extends ExploreEvent {
  final int limit;
  final int offset;

  GetHotLocations(this.limit, this.offset);
}

class GetRecentViewedLocations extends ExploreEvent {
  final int limit;

  GetRecentViewedLocations(this.limit);
}

class UpsertRecentViewedLocations extends ExploreEvent {
  final int locationId;
  final String userId;

  UpsertRecentViewedLocations(this.locationId, this.userId);
}
