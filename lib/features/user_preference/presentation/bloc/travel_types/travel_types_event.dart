part of 'travel_types_bloc.dart';

@immutable
sealed class TravelTypesEvent {}


class GetParentTravelTypes extends TravelTypesEvent {}

class GetTravelTypesByParentIds extends TravelTypesEvent {
  final List<String> parentIds;
  GetTravelTypesByParentIds(this.parentIds);
}
