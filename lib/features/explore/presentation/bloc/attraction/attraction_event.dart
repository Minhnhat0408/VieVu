part of 'attraction_bloc.dart';

@immutable
sealed class AttractionEvent {}


class GetHotAttractions extends AttractionEvent {
  final int limit;
  final int offset;

  GetHotAttractions({required this.limit, required this.offset});
}

class GetRecentViewedAttractions extends AttractionEvent {
  final int limit;

  GetRecentViewedAttractions(this.limit);
}

class UpsertRecentViewedAttractions extends AttractionEvent {
  final int attractionId;
  final String userId;

  UpsertRecentViewedAttractions(this.attractionId, this.userId);
}

class GetRecommendedAttraction extends AttractionEvent {
  final int limit;
  final String userId;

  GetRecommendedAttraction({required this.limit, required this.userId});
}
