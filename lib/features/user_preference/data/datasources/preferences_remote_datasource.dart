import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/user_preference/data/models/preference_model.dart';

abstract interface class PreferencesRemoteDataSource {
  Future<PreferenceModel?> getUserPreference({
    required String userId,
  });

  Future<PreferenceModel> updateUserPreference({
    required String userId,
    double? budget,
    double? avgRating,
    int? ratingCount,
    Map<String, dynamic>? prefsDF,
  });

  Future<PreferenceModel> insertUserPreference({
    required String userId,
    required double budget,
    required double avgRating,
    required int ratingCount,
    required Map<String, dynamic> prefsDF,
  });

  Future<PreferenceModel> updateUserPreferenceDF({
    required int attractionId,
    required PreferenceModel currentPref,
    required String action,
  });
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final SupabaseClient supabaseClient;

  PreferencesRemoteDataSourceImpl(
    this.supabaseClient,
  );

  @override
  Future<PreferenceModel?> getUserPreference({
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from('user_preferences')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return PreferenceModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PreferenceModel> updateUserPreference({
    required String userId,
    double? budget,
    double? avgRating,
    int? ratingCount,
    Map<String, dynamic>? prefsDF,
  }) async {
    try {
      // Dynamically build the data map
      final data = <String, dynamic>{};

      data['user_id'] = userId; // Always include user_id
      if (budget != null) data['budget'] = budget;
      if (avgRating != null) data['avg_rating'] = avgRating;
      if (ratingCount != null) data['rating_count'] = ratingCount;
      if (prefsDF != null) data['prefs_df'] = prefsDF;

      // Update the database with only the fields present in the data map
      final response = await supabaseClient
          .from('user_preferences')
          .update(data)
          .eq('user_id', userId)
          .select();

      return PreferenceModel.fromJson(response.first);
    } catch (e) {
      throw ServerException('Error updating user preferences: $e');
    }
  }

  @override
  Future<PreferenceModel> insertUserPreference({
    required String userId,
    required double budget,
    required double avgRating,
    required int ratingCount,
    required Map<String, dynamic> prefsDF,
  }) async {
    try {
      final response = await supabaseClient.from('user_preferences').insert({
        'user_id': userId,
        'budget': budget,
        'avg_rating': avgRating,
        'rating_count': ratingCount,
        'prefs_df': prefsDF,
      }).select();

      return PreferenceModel.fromJson(response.first);
    } catch (e) {
      throw ServerException('Error inserting user preferences: $e');
    }
  }

  @override
  Future<PreferenceModel> updateUserPreferenceDF({
    required int attractionId,
    required PreferenceModel currentPref,
    required String action,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException('User not authenticated');
      }

      final att = await supabaseClient
          .from('attractions')
          .select('attraction_types(type_name)')
          .eq('id', attractionId)
          .single();

      final travelTypes =
          (att['attraction_types'] as List).map((e) => e['type_name']).toList();

      double plusPoint = action == 'view'
          ? 1
          : action == 'search'
              ? 1.5
              : 2;
      double minScore = 0;
      double maxScore = 5;

      Map<String, double> newPref = Map.from(currentPref.prefsDF);

      for (String travelType in travelTypes) {
        final res = await supabaseClient
            .from('preference_history')
            .select()
            .eq('user_id', user.id)
            .eq('travel_type', travelType)
            .maybeSingle();

        if (res != null) {
          DateTime lastUpdated =
              DateTime.tryParse(res['updated_at'] ?? '')?.toUtc() ??
                  DateTime.now().toUtc();
          DateTime now = DateTime.now().toUtc();
          int hoursInactive = now.difference(lastUpdated).inHours;

          // Reduce plusPoint if last update was too recent (e.g., within 1 hour)
          if (hoursInactive < 1 && action == res['action']) {
            plusPoint *= 0.5; // Reduce by 50%
          }
        }

        // Increase score based on action
        final newScore =
            ((newPref[travelType] ?? 0) + plusPoint).clamp(minScore, maxScore);

        // Save to Supabase
        await supabaseClient.from('preference_history').upsert({
          'user_id': user.id,
          'travel_type': travelType,
          'updated_at': DateTime.now().toIso8601String(),
          'previous_score': newPref[travelType],
          'new_score': newScore,
          'action': action,
        }, onConflict: 'user_id, travel_type');

        newPref[travelType] = newScore;
      }

      await supabaseClient.from('user_preferences').update({
        'prefs_df': newPref,
      }).eq('user_id', user.id);

      return PreferenceModel(
        budget: currentPref.budget,
        avgRating: currentPref.avgRating,
        ratingCount: currentPref.ratingCount,
        prefsDF: newPref,
      );
    } catch (e) {
      log(e.toString());
      throw ServerException('Error updating user preferences: $e');
    }
  }
}
