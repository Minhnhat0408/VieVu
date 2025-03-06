part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetProfile extends ProfileEvent {
  final String id;

  GetProfile(this.id);
}

final class UpdateProfile extends ProfileEvent {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  UpdateProfile(this.id, this.email, this.firstName, this.lastName);
}
