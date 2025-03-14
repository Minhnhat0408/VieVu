part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetProfile extends ProfileEvent {
  final String id;

  GetProfile(this.id);
}

final class UpdateProfile extends ProfileEvent {

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? gender;
  final String? bio;
  final String? city;
  final File? avatar;

  UpdateProfile({

    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.bio,
    this.city,
    this.gender,
  });
}

final class ListenToUserLocations extends ProfileEvent {
  final String userId;
  final String tripId;

  ListenToUserLocations({
    required this.userId,
    required this.tripId,
  });
}

final class UserPositionReceived extends ProfileEvent {
  final UserPosition userPositionModel;

  UserPositionReceived(this.userPositionModel);
}
