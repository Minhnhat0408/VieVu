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

class GetRelatedAttractions extends AttractionEvent {
  final int attractionId;
  final int limit;

  GetRelatedAttractions({required this.attractionId, required this.limit});
}


class GetAttractionsWithFilter extends AttractionEvent {
  final String? categoryId1;
  final List<String>? categoryId2;
  final int limit;
  final int offset;
  final int? budget;
  final int? rating;
  final int locationId;
  final String sortType;
  final bool topRanked;

  GetAttractionsWithFilter({
    this.categoryId1,
    this.categoryId2,
    required this.limit,
    required this.offset,
    this.budget,
    this.rating,
    required this.locationId,
    required this.sortType,
    required this.topRanked,
  });
}