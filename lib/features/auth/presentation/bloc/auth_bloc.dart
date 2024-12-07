import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:supabase_flutter/supabase_flutter.dart" as supabase;
import "package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart";
import "package:vn_travel_companion/core/usecases/usecase.dart";
import "package:vn_travel_companion/features/auth/domain/entities/user.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/current_user.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/listen_auth_change.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/send_reset_password_email.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/update_password.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/user_login.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/user_logout.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/user_signup.dart";

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final UserLogout _userLogout;
  final ListenToAuthChanges _listenToAuthChanges;
  final SendResetPasswordEmail _sendEmailReset;
  final UpdatePassword _updatePassword;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserLogout userLogout,
    required ListenToAuthChanges listenToAuthChanges,
    required SendResetPasswordEmail sendEmailReset,
    required UpdatePassword updatePassword,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userLogout = userLogout,
        _listenToAuthChanges = listenToAuthChanges,
        _sendEmailReset = sendEmailReset,
        _updatePassword = updatePassword,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
    on<AuthLoginWithGoogle>(_onAuthLoginWithGoogle);
    on<AuthSendResetPasswordEmail>(_onSendResetPasswordEmail);
    on<AuthUpdatePassword>(_onUpdatePassword);
    _startUserSubscription();
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final res = await _userSignUp(UserSignUpParams(
        email: event.email, password: event.password, name: event.name));
    res.fold((e) => emit(AuthFailure(e.message)), (user) => AuthSuccess(user));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final res = await _userLogin(UserLoginParams.emailPassword(
        email: event.email, password: event.password));
    res.fold((e) => emit(AuthFailure(e.message)), (user) => AuthSuccess(user));
  }

  void _startUserSubscription() =>
      _listenToAuthChanges(NoParams()).listen((res) {
        if (res.event == supabase.AuthChangeEvent.passwordRecovery) {
          log("Password recovery");
          _appUserCubit.resetPassword();
        } else if (res.event == supabase.AuthChangeEvent.signedIn ||
            res.event == supabase.AuthChangeEvent.userUpdated) {
          log("User logged in");
          add(AuthUserLoggedIn());
        } else if (res.event == supabase.AuthChangeEvent.signedOut) {
          _appUserCubit.updateUser(null);
        }
      });

  void _isUserLoggedIn(AuthUserLoggedIn event, Emitter<AuthState> emit) async {
    final res = await _currentUser(NoParams());
    log('res: $res');

    res.fold((e) {
      _appUserCubit.updateUser(null);
      emit(AuthFailure(e.message));
    }, (user) => _emitAuthSuccess(user, emit));
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final res = await _userLogout(NoParams());
    res.fold((e) => emit(AuthFailure(e.message)), (_) {
      emit(AuthLogoutSuccess());
    });
  }

  void _onAuthLoginWithGoogle(
      AuthLoginWithGoogle event, Emitter<AuthState> emit) async {
    final res = await _userLogin(const UserLoginParams.google());

    res.fold((e) => emit(AuthFailure(e.message)), (user) => AuthSuccess(user));
  }

  void _onSendResetPasswordEmail(
      AuthSendResetPasswordEmail event, Emitter<AuthState> emit) async {
    final res = await _sendEmailReset(ResetEmailParams(email: event.email));
    res.fold((e) => emit(AuthFailure(e.message)), (_) {
      emit(AuthSendResetPasswordEmailSuccess());
    });
  }

  void _onUpdatePassword(
      AuthUpdatePassword event, Emitter<AuthState> emit) async {
    final res =
        await _updatePassword(UpdatePasswordParams(password: event.password));
    res.fold((e) => emit(AuthFailure(e.message)), (_) {
      emit(AuthUpdatePasswordSuccess());
    });
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
