import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart";
import "package:vn_travel_companion/core/usecases/usecase.dart";
import "package:vn_travel_companion/features/auth/domain/entities/user.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/current_user.dart";
import "package:vn_travel_companion/features/auth/domain/usecases/listen_auth_change.dart";
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
  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserLogout userLogout,
    required ListenToAuthChanges listenToAuthChanges,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userLogout = userLogout,
        _listenToAuthChanges = listenToAuthChanges,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
    on<AuthLoginWithGoogle>(_onAuthLoginWithGoogle);
    _startUserSubscription();
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final res = await _userSignUp(UserSignUpParams(
        email: event.email, password: event.password, name: event.name));
    res.fold((e) => emit(AuthFailure(e.message)),
        (user) => _emitAuthSuccess(user, emit));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final res = await _userLogin(UserLoginParams.emailPassword(
        email: event.email, password: event.password));
    res.fold((e) => emit(AuthFailure(e.message)),
        (user) => _emitAuthSuccess(user, emit));
  }

  void _startUserSubscription() => _listenToAuthChanges(NoParams())
      .listen((user) => add(AuthUserLoggedIn()));

  void _isUserLoggedIn(AuthUserLoggedIn event, Emitter<AuthState> emit) async { 
    final res = await _currentUser(NoParams());
    res.fold((e) {
      emit(AuthFailure(e.message));
    }, (user) => _emitAuthSuccess(user, emit));
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final res = await _userLogout(NoParams());
    res.fold((e) => emit(AuthFailure(e.message)), (_) {
      _appUserCubit.updateUser(null);
      emit(AuthLogoutSuccess());
    });
  }

  void _onAuthLoginWithGoogle(
      AuthLoginWithGoogle event, Emitter<AuthState> emit) async {
    final res = await _userLogin(const UserLoginParams.google());

    res.fold((e) => emit(AuthFailure(e.message)),
        (user) => _emitAuthSuccess(user, emit));
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}