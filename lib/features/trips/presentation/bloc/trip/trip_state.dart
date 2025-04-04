part of 'trip_bloc.dart';

@immutable
sealed class TripState {}

final class TripInitial extends TripState {}

final class TripLoading extends TripState {}

final class TripActionLoading extends TripState {}

final class TripDeletedSuccess extends TripState {}

final class TripActionSuccess extends TripState {
  final Trip trip;
  TripActionSuccess(this.trip);
}

final class TripActionFailure extends TripState {
  final String message;

  TripActionFailure(this.message);
}

final class SavedToTripLoadedSuccess extends TripState {
  final List<Trip> trips;

  SavedToTripLoadedSuccess(this.trips);
}

final class TripLoadedSuccess extends TripState {
  final List<Trip> trips;

  TripLoadedSuccess(this.trips);
}

final class TripLoadedFailure extends TripState {
  final String message;

  TripLoadedFailure(this.message);
}

final class TripPostsLoadedSuccess extends TripState {
  final List<Trip> trips;

  TripPostsLoadedSuccess(this.trips);
}
