part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileActionLoading extends ProfileState {}


final class ProfileLoadedSuccess extends ProfileState {
  final User user;

  ProfileLoadedSuccess({
    required this.user,
  });
}



final class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure({
    required this.message,
  });
}

final class ProfileUpdateSuccess extends ProfileState {
  final User user;

  ProfileUpdateSuccess({
    required this.user,ProfileFailure
  });
}


final class UserPositionReceivedSuccess extends ProfileState {
  final UserPosition userPositionModel;

  UserPositionReceivedSuccess(this.userPositionModel);
}
