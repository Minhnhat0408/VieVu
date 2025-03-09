part of 'current_trip_member_info_cubit.dart';

@immutable
sealed class CurrentTripMemberInfoState {}

final class CurrentTripMemberInfoInitial extends CurrentTripMemberInfoState {}

final class CurrentTripMemberInfoLoading extends CurrentTripMemberInfoState {}

final class CurrentTripMemberInfoLoaded extends CurrentTripMemberInfoState {
  final TripMember? tripMember;

  CurrentTripMemberInfoLoaded({
    required this.tripMember,
  });
}

final class CurrentTripMemberInfoError extends CurrentTripMemberInfoState {
  final String message;

  CurrentTripMemberInfoError({
    required this.message,
  });
}
