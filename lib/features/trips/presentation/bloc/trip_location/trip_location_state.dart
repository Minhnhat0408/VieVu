part of 'trip_location_bloc.dart';

@immutable
sealed class TripLocationState {}

final class TripLocationInitial extends TripLocationState {}

final class TripLocationLoading extends TripLocationState {}

final class TripLocationActionSucess extends TripLocationState {}

final class TripLocationFailure extends TripLocationState {
  final String message;

  TripLocationFailure({
    required this.message,
  });
}
