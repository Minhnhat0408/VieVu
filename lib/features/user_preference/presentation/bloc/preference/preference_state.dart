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



