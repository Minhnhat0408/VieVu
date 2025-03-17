part of 'preference_bloc.dart';

@immutable
sealed class PreferencesEvent {}

class UserPreferenceSignOut extends PreferencesEvent {} //sign out user
class GetUserPreference extends PreferencesEvent {
  final String userId;

  GetUserPreference(this.userId);
}

class UpdatePreference extends PreferencesEvent {
  final String userId;
  final double? budget;
  final double? avgRating;
  final int? ratingCount;
  final Map<String, dynamic>? prefsDF;

  UpdatePreference(
      {this.prefsDF,
      required this.userId,
      this.budget,
      this.avgRating,
      this.ratingCount});
}

class InsertPreference extends PreferencesEvent {
  final String userId;
  final double budget;
  final double avgRating;
  final int ratingCount;
  final Map<String, dynamic> prefsDF;

  InsertPreference({
    required this.userId,
    required this.budget,
    required this.avgRating,
    required this.ratingCount,
    required this.prefsDF,
  });
}


class UpdatePreferenceDF extends PreferencesEvent {
  final int attractionId;
  final Preference currentPref;
  final String action;

  UpdatePreferenceDF({
    required this.attractionId,
    required this.currentPref,
    required this.action,
  });
}
