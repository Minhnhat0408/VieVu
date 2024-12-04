part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserNotLoggedIn extends AppUserState {}
final class AppUserLoggedIn extends AppUserState {
  final User user;

  AppUserLoggedIn(this.user);
}

final class AppUserPasswordRecovery extends AppUserState {}

final class AppUserLoading extends AppUserState {}
