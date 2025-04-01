import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/auth/domain/repository/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  ProfileBloc({
    required ProfileRepository profileRepository,
  })  : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {});
    on<GetProfile>(_onGetProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileActionLoading());
    final res = await _profileRepository.updateProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      city: event.city,
      bio: event.bio,
      gender: event.gender,
      avatar: event.avatar,
    );
    res.fold(
      (l) => emit(ProfileFailure(message: l.message)),
      (r) => emit(ProfileUpdateSuccess(user: r)),
    );
  }

  void _onGetProfile(GetProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final res = await _profileRepository.getProfile(
      id: event.id,
    );
    res.fold(
      (l) => emit(ProfileFailure(message: l.message)),
      (r) => emit(ProfileLoadedSuccess(user: r)),
    );
  }
}
