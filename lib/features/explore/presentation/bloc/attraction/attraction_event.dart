part of 'attraction_bloc.dart';

@immutable
sealed class AttractionEvent {}

class GetHotAttractions extends AttractionEvent {
  final int limit;
  final int offset;
  final String userId;

  GetHotAttractions({required this.limit, required this.offset, required this.userId});
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
  final Preference userPref;

  GetRecommendedAttraction({required this.limit, required this.userPref});
}

class GetRelatedAttractions extends AttractionEvent {
  final int attractionId;
  final int limit;
  final String userId;


  GetRelatedAttractions({required this.attractionId, required this.limit, required this.userId});
}

class GetAttractionsWithFilter extends AttractionEvent {
  final String? categoryId1;
  final String userId;

  final List<String>? categoryId2;
  final int limit;
  final int offset;
  final int? budget;
  final int? rating;
  final double? lat;
  final double? lon;
  final int? proximity;
  final int? locationId;
  final String sortType;
  final bool topRanked;

  GetAttractionsWithFilter({
    this.categoryId1,
    this.categoryId2,
    required this.limit,
    required this.offset,
    this.budget,
    required this.userId,
    this.rating,
    this.lat,
    this.lon,
    this.proximity,
    this.locationId,
    required this.sortType,
    required this.topRanked,
  });
}
