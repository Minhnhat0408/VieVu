

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {

    });
    on<GetProfile>(_onGetProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    // final res = await _userSignUp(UserSignUpParams(
    //     email: event.email, password: event.password, name: event.name));
  }

  void _onGetProfile(GetProfile event, Emitter<ProfileState> emit) async {
    // final res = await _userSignUp(UserSignUpParams(
    //     email: event.email, password: event.password, name: event.name));
  }

}
