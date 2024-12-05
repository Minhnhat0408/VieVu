import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/preference.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/preference_repository.dart';

part 'preference_event.dart';
part 'preference_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferenceRepository _preferenceRepository;
  PreferencesBloc({
    required PreferenceRepository preferenceRepository,
  })  : _preferenceRepository = preferenceRepository,
        super(PreferencesInitial()) {
    on<GetUserPreference>(_onGetPreference);
    on<UpdatePreference>(_onUpdatePreference);
    on<InsertPreference>(_onInsertPreference);
    on<UserPreferenceSignOut>(_onSignOut);
  }

  void _onGetPreference(
      GetUserPreference event, Emitter<PreferencesState> emit) async {
    final res =
        await _preferenceRepository.getUserPreference(userId: event.userId);
    res.fold(
      (l) => emit(PreferencesFailure(l.message)),
      (r) {
        if (r == null) {
          emit(NoPreferencesExits());
        } else {
          emit(PreferencesLoadedSuccess(r));
        }
      },
    );
  }

  void _onSignOut(UserPreferenceSignOut event, Emitter<PreferencesState> emit) {
    emit(PreferencesInitial());
  }

  void _onUpdatePreference(
      UpdatePreference event, Emitter<PreferencesState> emit) async {
    emit(PreferencesLoading());
    final res = await _preferenceRepository.updateUserPreference(
      userId: event.userId,
      budget: event.budget,
      avgRating: event.avgRating,
      ratingCount: event.ratingCount,
      prefsDF: event.prefsDF,
    );
    res.fold(
      (l) => emit(PreferencesFailure(l.message)),
      (r) => emit(PreferencesLoadedSuccess(r)),
    );
  }

  void _onInsertPreference(
      InsertPreference event, Emitter<PreferencesState> emit) async {
    emit(PreferencesLoading());
    final res = await _preferenceRepository.insertUserPreference(
      userId: event.userId,
      budget: event.budget,
      avgRating: event.avgRating,
      ratingCount: event.ratingCount,
      prefsDF: event.prefsDF,
    );
    res.fold(
      (l) => emit(PreferencesFailure(l.message)),
      (r) => emit(PreferencesLoadedSuccess(r)),
    );
  }
}
