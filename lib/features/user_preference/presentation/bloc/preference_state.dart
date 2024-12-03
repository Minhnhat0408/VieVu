part of 'preference_bloc.dart';

@immutable
sealed class PreferencesState {}

final class PreferencesInitial extends PreferencesState {}

final class PreferencesLoading extends PreferencesState {}

final class PreferencesLoadedSuccess extends PreferencesState {
  final Preference preference;

  PreferencesLoadedSuccess(this.preference);
}

final class NoPreferencesExits extends PreferencesState {}

final class PreferencesFailure extends PreferencesState {
  final String message;

  PreferencesFailure(this.message);
}

final class TravelTypesLoadedSuccess extends PreferencesState {
  final List<TravelType> travelTypes;

  TravelTypesLoadedSuccess(this.travelTypes);
}

final class TravelTypesFailure extends PreferencesState {
  final String message;

  TravelTypesFailure(this.message);
}
