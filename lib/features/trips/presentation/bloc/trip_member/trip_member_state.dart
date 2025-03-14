part of 'trip_member_bloc.dart';

@immutable
sealed class TripMemberState {}

final class TripMemberInitial extends TripMemberState {}

final class TripMemberLoading extends TripMemberState {}

final class TripMemberActionLoading extends TripMemberState {}

final class TripMemberDeletedSuccess extends TripMemberState {
  final String tripMemberId;

  TripMemberDeletedSuccess({
    required this.tripMemberId,
  });
}

final class TripMemberLoadedSuccess extends TripMemberState {
  final List<TripMember> tripMembers;

  TripMemberLoadedSuccess({required this.tripMembers});
}

final class TripMemberFailure extends TripMemberState {
  final String message;

  TripMemberFailure({
    required this.message,
  });
}

final class TripMemberInsertedSuccess extends TripMemberState {
  final TripMember tripMember;

  TripMemberInsertedSuccess({
    required this.tripMember,
  });
}

final class TripMemberUpdatedSuccess extends TripMemberState {
  final TripMember tripMember;

  TripMemberUpdatedSuccess({
    required this.tripMember,
  });
}

final class TripMemberRatedSuccess extends TripMemberState {}
