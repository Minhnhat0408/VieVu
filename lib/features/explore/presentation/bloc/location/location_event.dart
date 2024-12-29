part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

final class GetLocation extends LocationEvent {
  final int locationId;

  GetLocation({
    required this.locationId,
  });
}

final class GetHotLocations extends LocationEvent {
  final int limit;
  final int offset;

  GetHotLocations({
    required this.limit,
    required this.offset,
  });
}

final class GetRecentViewedLocations extends LocationEvent {
  final int limit;

  GetRecentViewedLocations({
    required this.limit,
  });
}

final class UpsertRecentViewedLocations extends LocationEvent {
  final int locationId;
  final String userId;

  UpsertRecentViewedLocations({
    required this.locationId,
    required this.userId,
  });
}

