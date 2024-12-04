part of 'travel_types_bloc.dart';

@immutable
sealed class TravelTypesState {}

final class TravelTypesInitial extends TravelTypesState {}

final class TravelTypesLoading extends TravelTypesState {}

final class TravelTypesLoadedSuccess extends TravelTypesState {
  final List<TravelType> travelTypes;

  TravelTypesLoadedSuccess(this.travelTypes);
}

final class TravelTypesFailure extends TravelTypesState {
  final String message;

  TravelTypesFailure(this.message);
}
