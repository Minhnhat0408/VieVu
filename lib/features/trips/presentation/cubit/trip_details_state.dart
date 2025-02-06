part of 'trip_details_cubit.dart';

@immutable
sealed class TripDetailsState {}

final class TripDetailsInitial extends TripDetailsState {}

final class TripDetailsLoading extends TripDetailsState {}


final class TripDetailsLoadedSuccess extends TripDetailsState {
  final Trip trip;
  TripDetailsLoadedSuccess(this.trip);
}

final class TripDetailsLoadedFailure extends TripDetailsState {
  final String message;

  TripDetailsLoadedFailure(this.message);
}
