import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/preference.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/preference_repository.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/travel_type_repository.dart';

part 'preference_event.dart';
part 'preference_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferenceRepository _preferenceRepository;
  final TravelTypeRepository _travelTypeRepository;
  PreferencesBloc({
    required PreferenceRepository preferenceRepository,
    required TravelTypeRepository travelTypeRepository,
  })  : _preferenceRepository = preferenceRepository,
        _travelTypeRepository = travelTypeRepository,
        super(PreferencesInitial()) {
    on<PreferencesEvent>((event, emit) => emit(PreferencesLoading()));
    on<GetUserPreference>(_onGetPreference);
    on<UpdatePreference>(_onUpdatePreference);
    on<InsertPreference>(_onInsertPreference);
    on<GetParentTravelTypes>(_onGetParentTravelTypes);
    on<GetTravelTypesByParentIds>(_onGetTravelTypesByParentIds);
  }

  void _onGetParentTravelTypes(
      GetParentTravelTypes event, Emitter<PreferencesState> emit) async {
    final res = await _travelTypeRepository.getParentTravelTypes();
    res.fold(
      (l) => emit(TravelTypesFailure(l.message)),
      (r) => emit(TravelTypesLoadedSuccess(r)),
    );
  }

  void _onGetTravelTypesByParentIds(
      GetTravelTypesByParentIds event, Emitter<PreferencesState> emit) async {
    final res = await _travelTypeRepository.getTravelTypesByParentIds(
        parentIds: event.parentIds);
    res.fold(
      (l) => emit(TravelTypesFailure(l.message)),
      (r) => emit(TravelTypesLoadedSuccess(r)),
    );
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

  void _onUpdatePreference(
      UpdatePreference event, Emitter<PreferencesState> emit) async {
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
