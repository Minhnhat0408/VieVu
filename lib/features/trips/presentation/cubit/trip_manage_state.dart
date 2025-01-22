part of 'trip_manage_cubit.dart';

@immutable
sealed class TripManageState {}

final class TripManageInitial extends TripManageState {}

final class TripManageLoading extends TripManageState {}

final class TripManageActionSuccess extends TripManageState {}

final class TripManageLoadedFailure extends TripManageState {
  final String message;

  TripManageLoadedFailure(this.message);
}
