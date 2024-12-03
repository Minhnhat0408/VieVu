import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/user_preference/data/models/preference_model.dart';

abstract interface class PreferencesRemoteDataSource {
  Future<PreferenceModel?> getUserPreference({
    required String userId,
  });

  Future<PreferenceModel> updateUserPreference({
    required String userId,
    String? budget,
    String? avgRating,
    String? ratingCount,
    Map<String, dynamic>? prefsDF,
  });

  Future<PreferenceModel> insertUserPreference({
    required String userId,
    required String budget,
    required String avgRating,
    required String ratingCount,
    required Map<String, dynamic> prefsDF,
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
      throw const ServerException('Error getting user preferences');
    }
  }

  @override
  Future<PreferenceModel> updateUserPreference({
    required String userId,
    String? budget,
    String? avgRating,
    String? ratingCount,
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
      await supabaseClient
          .from('user_preferences')
          .update(data)
          .eq('user_id', userId)
          .select();

      return PreferenceModel.fromJson(data);
    } catch (e) {
      throw ServerException('Error updating user preferences: $e');
    }
  }

  @override
  Future<PreferenceModel> insertUserPreference({
    required String userId,
    required String budget,
    required String avgRating,
    required String ratingCount,
    required Map<String, dynamic> prefsDF,
  }) async {
    try {
      await supabaseClient.from('user_preferences').insert({
        'user_id': userId,
        'budget': budget,
        'avg_rating': avgRating,
        'rating_count': ratingCount,
        'prefs_df': prefsDF,
      }).select();

      return PreferenceModel.fromJson({
        'user_id': userId,
        'budget': budget,
        'avg_rating': avgRating,
        'rating_count': ratingCount,
        'prefs_df': prefsDF,
      });
    } catch (e) {
      throw ServerException('Error inserting user preferences: $e');
    }
  }
}
